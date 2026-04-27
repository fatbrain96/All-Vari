package com.vari.backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;
import java.net.URI;
import java.net.URISyntaxException;

@Configuration
@Profile("production")
public class RenderDatabaseConfig {

    @Bean
    public DataSource dataSource(Environment env) throws URISyntaxException {
        String databaseUrl = env.getProperty("DATABASE_URL");
        
        if (databaseUrl == null || databaseUrl.isEmpty()) {
            throw new IllegalStateException("DATABASE_URL environment variable is not set");
        }
        
        System.out.println("DATABASE_URL: " + databaseUrl.substring(0, Math.min(50, databaseUrl.length())) + "...");
        
        // Parse the DATABASE_URL
        // Format: postgresql://user:password@host:port/database
        URI dbUri = new URI(databaseUrl);
        
        String host = dbUri.getHost();
        int port = dbUri.getPort() != -1 ? dbUri.getPort() : 5432;
        String database = dbUri.getPath().substring(1); // Remove leading /
        String username = dbUri.getUserInfo().split(":")[0];
        String password = dbUri.getUserInfo().split(":")[1];
        
        String jdbcUrl = String.format("jdbc:postgresql://%s:%d/%s", host, port, database);
        
        System.out.println("Parsed JDBC URL: " + jdbcUrl.substring(0, Math.min(50, jdbcUrl.length())) + "...");
        System.out.println("Username: " + username);
        
        return DataSourceBuilder.create()
                .driverClassName("org.postgresql.Driver")
                .url(jdbcUrl)
                .username(username)
                .password(password)
                .build();
    }
}
