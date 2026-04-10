package com.vari.backend.service;

import com.vari.backend.model.AshaWorker;
import com.vari.backend.repository.AshaWorkerRepository;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.Random;
import java.util.List;
import java.security.MessageDigest;
import java.util.Base64;

@Service
public class AshaWorkerService {

    @Autowired
    private AshaWorkerRepository repository;

    public AshaWorker provisionNewWorker(String firstName, String lastName, String village, String phone, Integer age, String block) {
        String generatedId = generateUniqueId(firstName, lastName);
        String plainTextPassword = generateRandomDigits(8); // Generate temporary PIN

        AshaWorker newWorker = new AshaWorker();
        newWorker.setAshaId(generatedId);

        // Hash the password before storing in database
        newWorker.setPin(hashPassword(plainTextPassword));

        newWorker.setName(firstName + " " + lastName);
        newWorker.setAssignedVillage(village);
        newWorker.setPhone(phone);
        newWorker.setAge(age);
        newWorker.setBlock(block);
        newWorker.setFirstLogin(true); // Mark as first login

        // Return the plain text password to admin for one-time display
        // The database stores the hashed version for security
        AshaWorker savedWorker = repository.save(newWorker);
        savedWorker.setPin(plainTextPassword);
        return savedWorker;
    }

    private String generateUniqueId(String firstName, String lastName) {
        String firstThree = getFirstThreeLetters(firstName);
        String attempt = firstThree + generateRandomDigits(3);

        if (!repository.existsByAshaId(attempt)) {
            return attempt;
        }

        String lastThree = getFirstThreeLetters(lastName);
        attempt = lastThree + generateRandomDigits(3);

        while (repository.existsByAshaId(attempt)) {
            attempt = lastThree + generateRandomDigits(3);
        }

        return attempt;
    }

    private String getFirstThreeLetters(String name) {
        if (name == null || name.trim().isEmpty()) return "USR";
        if (name.length() < 3) return name.toUpperCase();
        return name.substring(0, 3).toUpperCase();
    }

    private String generateRandomDigits(int length) {
        Random random = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            sb.append(random.nextInt(10));
        }
        return sb.toString();
    }

    public List<AshaWorker> getAllWorkers() {
        return repository.findAll();
    }

    // Secure password hashing using SHA-256
    public String hashPassword(String plainText) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(plainText.getBytes("UTF-8"));
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("Failed to hash password", e);
        }
    }
}