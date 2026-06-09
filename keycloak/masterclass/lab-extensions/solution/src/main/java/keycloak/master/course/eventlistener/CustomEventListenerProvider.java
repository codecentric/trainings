package keycloak.master.course.eventlistener;

import org.jboss.logging.Logger;
import org.keycloak.events.Event;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.admin.AdminEvent;

public class CustomEventListenerProvider implements EventListenerProvider {

    private static final Logger logger = Logger.getLogger(CustomEventListenerProvider.class);

    @Override
    public void onEvent(Event event) {
        logger.infof("User Event: type=%s, realmId=%s, clientId=%s, userId=%s, ipAddress=%s",
                event.getType(),
                event.getRealmId(),
                event.getClientId(),
                event.getUserId(),
                event.getIpAddress());
    }

    @Override
    public void onEvent(AdminEvent adminEvent, boolean includeRepresentation) {
        logger.infof("Admin Event: operationType=%s, resourceType=%s, resourcePath=%s, realmId=%s",
                adminEvent.getOperationType(),
                adminEvent.getResourceType(),
                adminEvent.getResourcePath(),
                adminEvent.getRealmId());
    }

    @Override
    public void close() {
    }
}
