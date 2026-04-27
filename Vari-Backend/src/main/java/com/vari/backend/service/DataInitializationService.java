package com.vari.backend.service;

import com.vari.backend.model.AshaWorker;
import com.vari.backend.model.HealthReport;
import com.vari.backend.model.Victim;
import com.vari.backend.repository.AshaWorkerRepository;
import com.vari.backend.repository.HealthReportRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Arrays;

@Service
public class DataInitializationService implements CommandLineRunner {

    @Autowired
    private AshaWorkerRepository workerRepository;
    
    @Autowired
    private HealthReportRepository reportRepository;
    
    @Autowired
    private AshaWorkerService workerService;

    @Override
    public void run(String... args) throws Exception {
        // Initialize with your existing workers from Saturday
        initializeWorkers();
        initializeHealthReports();
    }

    private void initializeWorkers() {
        // Only initialize if database is empty
        if (workerRepository.count() == 0) {
            createWorker("SAK744", "Sakshi", "Dhoni", "Ranchi", "9876543210", 25, "Ranchi Block", "31331025");
            createWorker("RIT146", "Ritika", "Sharma", "Mumbai", "9876543211", 28, "Mumbai Block", "88307820");
            createWorker("SON448", "Sonpari", "Chauhan", "Sonbhadra", "9876543212", 30, "Sonbhadra Block", "51865814");
            createWorker("KAV354", "Kavya", "Patel", "Ahmedabad", "9876543213", 26, "Ahmedabad Block", "12345678");
            
            System.out.println("Initialized " + workerRepository.count() + " ASHA workers");
        }
    }

    private void initializeHealthReports() {
        // Only initialize if no reports exist
        if (reportRepository.count() == 0) {
            // Create sample reports with victims
            createSampleReport("SAK744", 23.3441, 85.3096, 6.8, 450.0, "Unsafe", "Ranchi Water Source", 
                Arrays.asList(
                    new String[]{"Priya Sharma", "28", "Female", "Diarrhea", "3 days"},
                    new String[]{"Raj Kumar", "35", "Male", "Stomach Pain", "2 days"}
                ));
                
            createSampleReport("RIT146", 19.0760, 72.8777, 7.2, 320.0, "Safe", "Mumbai Water Point", 
                Arrays.asList());
                
            createSampleReport("SON448", 25.2138, 83.0764, 6.5, 520.0, "Unsafe", "Sonbhadra Well", 
                Arrays.asList(
                    new String[]{"Sunita Devi", "42", "Female", "Fever", "4 days"}
                ));
                
            createSampleReport("KAV354", 23.0225, 72.5714, 7.5, 280.0, "Safe", "Ahmedabad Supply", 
                Arrays.asList());
                
            System.out.println("Initialized " + reportRepository.count() + " health reports");
        }
    }

    private void createWorker(String ashaId, String firstName, String lastName, String village, 
                            String phone, Integer age, String block, String plainPin) {
        AshaWorker worker = new AshaWorker();
        worker.setAshaId(ashaId);
        worker.setName(firstName + " " + lastName);
        worker.setAssignedVillage(village);
        worker.setPhone(phone);
        worker.setAge(age);
        worker.setBlock(block);
        worker.setPin(workerService.hashPassword(plainPin)); // Hash the PIN
        worker.setFirstLogin(false); // Set to false since these are existing workers
        
        workerRepository.save(worker);
    }
    
    private void createSampleReport(String ashaId, Double lat, Double lng, Double ph, Double tds, 
                                  String status, String location, java.util.List<String[]> victimData) {
        HealthReport report = new HealthReport();
        report.setAshaId(ashaId);
        report.setLatitude(lat);
        report.setLongitude(lng);
        report.setPhLevel(ph);
        report.setTdsLevel(tds);
        report.setTurbidity(2.5);
        report.setStatus(status);
        report.setLocation(location);
        report.setCreatedAt(LocalDateTime.now().minusDays((long)(Math.random() * 7))); // Random date within last week
        
        // Add victims if any
        for (String[] victimInfo : victimData) {
            Victim victim = new Victim();
            victim.setName(victimInfo[0]);
            victim.setAge(Integer.parseInt(victimInfo[1]));
            victim.setGender(victimInfo[2]);
            victim.setDisease(victimInfo[3]);
            victim.setDuration(victimInfo[4]);
            victim.setWeight(60.0 + Math.random() * 20); // Random weight between 60-80kg
            victim.setContactNumber("98765432" + (10 + (int)(Math.random() * 90)));
            victim.setSymptomDays(Integer.parseInt(victimInfo[4].split(" ")[0]));
            victim.setHasPriorMedication(Math.random() > 0.5);
            victim.setHealthReport(report);
            
            report.getVictims().add(victim);
        }
        
        reportRepository.save(report);
    }
}