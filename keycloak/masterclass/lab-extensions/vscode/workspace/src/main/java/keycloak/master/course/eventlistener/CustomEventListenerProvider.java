package keycloak.master.course.eventlistener;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class CustomEventListenerProvider {


    private Logger logger = LoggerFactory.getLogger(CustomEventListenerProvider.class);

    public CustomEventListenerProvider() {
        logger.info("Instantiated CustomEventListenerProvider");
    }

}
