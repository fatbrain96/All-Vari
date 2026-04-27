package com.vari.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class HealthController {

    @Autowired
    private DataSource dataSource;

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "Vari Backend");
        response.put("version", "1.0.0");
        response.put("status", "UP");
        
        // Test database connection
        try (Connection connection = dataSource.getConnection()) {
            response.put("database", "Connected");
            response.put("dbUrl", connection.getMetaData().getURL());
        } catch (Exception e) {
            response.put("database", "Failed: " + e.getMessage());
        }
        
        return response;
    }
}