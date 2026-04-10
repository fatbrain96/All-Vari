package com.vari.backend.model;

import jakarta.persistence.*;

@Entity
@Table(name = "asha_workers")
public class AshaWorker {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String ashaId;
    private String name;
    private String phone;
    private String pin;
    private String assignedVillage;
    private Integer age;
    private String block;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getAshaId() { return ashaId; }
    public void setAshaId(String ashaId) { this.ashaId = ashaId; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public String getPin() { return pin; }
    public void setPin(String pin) { this.pin = pin; }
    
    public String getAssignedVillage() { return assignedVillage; }
    public void setAssignedVillage(String assignedVillage) { this.assignedVillage = assignedVillage; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    public String getBlock() { return block; }
    public void setBlock(String block) { this.block = block; }

    // Add this to your AshaWorker.java properties
    private boolean isFirstLogin = true;

    // Generate the Getter and Setter!
    public boolean isFirstLogin() { return isFirstLogin; }
    public void setFirstLogin(boolean firstLogin) { this.isFirstLogin = firstLogin; }
}
