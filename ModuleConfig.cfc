/**
 * I am a ColdBox module that adds a host header to the response to show the host of the server creating the response. This is very useful in cluster setups or docker swarms.
 */
component {

	this.name = "HostnameHeader";
	this.author = "Gavin Pickin";
	this.webUrl = "https://github.com/gpickin/HostnameHeader";

	function configure() {

	}

	/**
	 * This function is the core of the Hostname header module. This fires on onRequestCapture and adds the hostname of the server to the event headers with the key X-Server-Hostname
	 * @event
	 * @interceptData
	 * @buffer
	 * @rc
	 * @prc
	 */
	function onRequestCapture( event, interceptData, buffer, rc, prc ) {

		prc.hostnameHeader = {};
		prc.hostnameHeader.hostname = "";
		if( structKeyExists( server.os, "hostname" ) and len( server.os.hostname ) ){
			prc.hostnameHeader.hostname = server.os.hostname;
		}
		if( structKeyExists( server, "x_hostname" ) and len( server.x_hostname ) ){
			prc.hostnameHeader.hostname = server.x_hostname;
		}
		if( !len( prc.hostnameHeader.hostname ) ){
			try {
				prc.hostnameHeader.hostname = fileRead( '/etc/hostname' );
			} catch ( any e ){
				prc.hostnameHeader.fileError = e.message;
			}
		}
		if( !len( prc.hostnameHeader.hostname ) ){
			try {
				var inet = CreateObject("java", "java.net.InetAddress");
				prc.hostnameHeader.hostname = inet.getLocalHost().getHostName();
			} catch ( any e ){
				// Log errors
				prc.hostnameHeader.javaError = e.message;
			}
		}
		server.x_hostname = prc.hostnameHeader.hostname;

		if ( isCachedEvent( event ) ) {
			return;
		}

		event.setHTTPHeader( name = "x-server-hostname", value = prc.hostnameHeader.hostname );
	}

	private function isCachedEvent( event ) {
		return structKeyExists( event.getEventCacheableEntry(), "cacheKey" ) &&
			getController().getCache( "template" ).lookup( event.getEventCacheableEntry().cacheKey );
	}
}