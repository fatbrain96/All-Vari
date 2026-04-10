package com.vari.backend.controller;

import com.vari.backend.dto.WorkerRequestDTO;
import com.vari.backend.service.AshaWorkerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AshaWorkerService ashaWorkerService;

    @PostMapping("/workers")
    public ResponseEntity<?> registerWorker(@RequestBody WorkerRequestDTO request) {
        try {
            var newWorker = ashaWorkerService.provisionNewWorker(
                request.getFirstName(),
                request.getLastName(),
                request.getVillage(),
                request.getPhone(),
                    request.getAge(),
                    request.getBlock()
            );
            return ResponseEntity.ok(newWorker);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
    @GetMapping("/workers")
    public ResponseEntity<?> getAllWorkers() {
        try {
            return ResponseEntity.ok(ashaWorkerService.getAllWorkers());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
}