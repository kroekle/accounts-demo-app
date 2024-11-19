package com.styra.demo.accounts;

import java.util.Collections;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AccountsServiceApplication {

	private static final Logger logger = LoggerFactory.getLogger(AccountsServiceApplication.class);

	public static void main(String[] args) {
		String port = System.getenv("PORT");
		if (port == null) {
		  port = "8081";
		  logger.warn("$PORT environment variable not set, defaulting to {}", port);
		}

		SpringApplication app;
		boolean useUsController = Boolean.parseBoolean(System.getenv().getOrDefault("US_CONTROLLER", "true"));
		if (useUsController) {
		  logger.info("Using US Accounts Rest Controller");
		  app = new SpringApplication(AccountsServiceApplication.class, UsAccountsRestController.class);
		} else {
		  logger.info("Using Global Accounts Rest Controller");
		  app = new SpringApplication(AccountsServiceApplication.class, GlobalAccountsRestController.class);
		}
		// SpringApplication app = new SpringApplication(AccountsServiceApplication.class, UsAccountsRestController.class);

		app.setDefaultProperties(Collections.singletonMap("server.port", port));

		// Start the Spring Boot application.
		app.run(args);
		logger.info("The container started successfully and is listening for HTTP requests on {}", port);
	}

}
