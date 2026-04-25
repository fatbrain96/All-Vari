package com.vari.backend.controller;

import com.vari.backend.model.HealthReport;
import com.vari.backend.model.Victim;
import com.vari.backend.repository.HealthReportRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.CrossOrigin;

@RestController
@CrossOrigin(origins = "*")
public class HealthReportController {

    @Autowired
    private HealthReportRepository healthReportRepository;

    // Fetch all health reports sorted by creation date
    @GetMapping("/api/reports")
    public ResponseEntity<List<HealthReport>> getAllHealthReports() {
        try {
            // Sort by createdAt in descending order (newest first)
            List<HealthReport> reports = healthReportRepository.findAll(
                Sort.by(Sort.Direction.DESC, "createdAt")
            );
            return ResponseEntity.ok(reports);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping("/api/reports")
    public ResponseEntity<HealthReport> createHealthReport(@RequestBody HealthReport healthReport) {
        try {
            // Smart water safety calculation with victim tracking

            // Calculate water safety status automatically
            String calculatedStatus = determineWaterSafety(
                    healthReport.getPhLevel(),
                    healthReport.getTdsLevel(),
                    healthReport.getTurbidity(),
                    healthReport.getVictims() // ✅ Now considers victims too
            );

            // 2. Set calculated status and timestamp
            healthReport.setStatus(calculatedStatus);
            healthReport.setCreatedAt(LocalDateTime.now());

            // 3. LINK VICTIMS TO THE REPORT (Crucial Step!)
            // This loop tells every 'Victim' who their parent 'Report' is.
            if (healthReport.getVictims() != null) {
                for (Victim v : healthReport.getVictims()) {
                    v.setHealthReport(healthReport);
                }
            }

            // End of smart logic processing

            // Save the report (cascade will save victims automatically)
            HealthReport savedReport = healthReportRepository.save(healthReport);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedReport);

        } catch (Exception e) {
            e.printStackTrace(); // Helpful to see errors in the console
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // Helper method to determine water safety based on parameters and victims
    private String determineWaterSafety(Double ph, Double tds, Double turbidity, List<Victim> victims) {
        // Handle null values gracefully
        if (ph == null || tds == null || turbidity == null) {
            return "Unknown";
        }

        boolean isPhBad = (ph < 6.5 || ph > 8.5);
        boolean isTdsBad = (tds > 250); // Using your limit of 250
        boolean isTurbidityBad = (turbidity > 5.0);
        boolean hasVictims = (victims != null && !victims.isEmpty()); // ✅ NEW: Check for health impact

        if (isPhBad || isTdsBad || isTurbidityBad || hasVictims) {
            return "Unsafe";
        } else {
            return "Safe";
        }
    }
}