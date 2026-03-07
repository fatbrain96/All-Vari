package com.vari.backend.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "victims")
public class Victim {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private Integer age;
    private String gender;
    private String disease;
    private String duration; // Keeping for backward compatibility

    // 🆕 NEW MEDICAL FIELDS
    private Double weight;
    private String contactNumber;
    private Integer symptomDays; // "Days till symptoms"
    private String patientImageUrl; // URL to the image
    private Boolean hasPriorMedication;
    private String priorMedicationName;

    @ManyToOne
    @JoinColumn(name = "report_id")
    @JsonBackReference
    private HealthReport healthReport;

    // Constructors
    public Victim() {}

    public Victim(String name, Integer age, String gender, String disease, String duration) {
        this.name = name;
        this.age = age;
        this.gender = gender;
        this.disease = disease;
        this.duration = duration;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getDisease() { return disease; }
    public void setDisease(String disease) { this.disease = disease; }

    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }

    // 🆕 NEW MEDICAL FIELD GETTERS AND SETTERS
    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public Integer getSymptomDays() { return symptomDays; }
    public void setSymptomDays(Integer symptomDays) { this.symptomDays = symptomDays; }

    public String getPatientImageUrl() { return patientImageUrl; }
    public void setPatientImageUrl(String patientImageUrl) { this.patientImageUrl = patientImageUrl; }

    public Boolean getHasPriorMedication() { return hasPriorMedication; }
    public void setHasPriorMedication(Boolean hasPriorMedication) { this.hasPriorMedication = hasPriorMedication; }

    public String getPriorMedicationName() { return priorMedicationName; }
    public void setPriorMedicationName(String priorMedicationName) { this.priorMedicationName = priorMedicationName; }

    public HealthReport getHealthReport() { return healthReport; }
    public void setHealthReport(HealthReport healthReport) { this.healthReport = healthReport; }
}