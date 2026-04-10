package com.vari.backend.controller;

import com.vari.backend.model.AshaWorker;
import com.vari.backend.repository.AshaWorkerRepository;
import com.vari.backend.service.AshaWorkerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {
    
    @Autowired
    private AshaWorkerRepository repository;
    
    @Autowired
    private AshaWorkerService workerService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        String ashaId = credentials.get("ashaId");
        String pin = credentials.get("pin");
        
        // Hash the incoming plain-text pin
        String hashedPin = workerService.hashPassword(pin);
        
        // Check database using the HASHED pin
        Optional<AshaWorker> worker = repository.findByAshaIdAndPin(ashaId, hashedPin);
        
        if (worker.isPresent()) {
            return ResponseEntity.ok(worker.get());
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid ASHA ID or PIN");
        }
    }
    
    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> request) {
        String ashaId = request.get("ashaId");
        String newPin = request.get("newPin");
        
        // Fetch the worker using ashaId
        Optional<AshaWorker> workerOptional = repository.findByAshaId(ashaId);
        
        if (workerOptional.isPresent()) {
            AshaWorker worker = workerOptional.get();
            
            // Update their PIN using hashed password
            worker.setPin(workerService.hashPassword(newPin));
            
            // Set their first login flag to false
            worker.setFirstLogin(false);
            
            // Save the worker
            repository.save(worker);
            
            return ResponseEntity.ok("Password updated successfully");
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Worker not found");
        }
    }
}
