package com.vari.backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;

import java.util.HashMap;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class HealthController {

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("service", "Vari Backend");
        response.put("version", "1.0.0");
        response.put("status", "UP");
        response.put("message", "Vari Healthcare Platform is running successfully!");
        return response;
    }
}