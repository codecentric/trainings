package keycloak.master.course.eventlistener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *  Hint: This class needs to implement the interface EventListenerProvider
 */
public class CustomEventListenerProvider {

    private Logger logger = LoggerFactory.getLogger(
        CustomEventListenerProvider.class
    );

    public CustomEventListenerProvider() {
        logger.info("Instantiated CustomEventListenerProvider");
    }
}
