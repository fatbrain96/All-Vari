package com.vari.backend.service;

import com.vari.backend.model.AshaWorker;
import com.vari.backend.repository.AshaWorkerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Service;

@Service
public class DataInitializationService implements CommandLineRunner {

    @Autowired
    private AshaWorkerRepository repository;
    
    @Autowired
    private AshaWorkerService workerService;

    @Override
    public void run(String... args) throws Exception {
        // Initialize with your existing workers from Saturday
        initializeWorkers();
    }

    private void initializeWorkers() {
        // Only initialize if database is empty
        if (repository.count() == 0) {
            createWorker("SAK744", "Sakshi", "Dhoni", "Ranchi", "9876543210", 25, "Ranchi Block", "31331025");
            createWorker("RIT146", "Ritika", "Sharma", "Mumbai", "9876543211", 28, "Mumbai Block", "88307820");
            createWorker("SON448", "Sonpari", "Chauhan", "Sonbhadra", "9876543212", 30, "Sonbhadra Block", "51865814");
            createWorker("KAV354", "Kavya", "Patel", "Ahmedabad", "9876543213", 26, "Ahmedabad Block", "12345678");
            
            System.out.println("Initialized " + repository.count() + " ASHA workers");
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
        
        repository.save(worker);
    }
}