package com.vari.backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;

@Configuration
@Profile("production")
public class DataSourceConfig {

    @Bean
    public DataSource dataSource() {
        String databaseUrl = System.getenv("DATABASE_URL");
        
        if (databaseUrl == null || databaseUrl.isEmpty()) {
            throw new IllegalStateException("DATABASE_URL environment variable is not set");
        }
        
        System.out.println("DATABASE_URL found: " + databaseUrl.substring(0, Math.min(50, databaseUrl.length())) + "...");
        
        // Convert postgresql:// to jdbc:postgresql://
        String jdbcUrl = databaseUrl;
        if (databaseUrl.startsWith("postgresql://")) {
            jdbcUrl = "jdbc:" + databaseUrl;
        }
        
        System.out.println("JDBC URL: " + jdbcUrl.substring(0, Math.min(50, jdbcUrl.length())) + "...");
        
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(jdbcUrl);
        config.setMaximumPoolSize(5);
        config.setMinimumIdle(2);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        config.setAutoCommit(true);
        
        return new HikariDataSource(config);
    }
}
