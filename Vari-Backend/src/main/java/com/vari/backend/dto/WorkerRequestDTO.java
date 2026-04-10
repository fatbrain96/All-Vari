package com.vari.backend.dto; // Make sure this matches your actual package name!

public class WorkerRequestDTO {
    private String firstName;
    private String lastName;
    private String village;
    private String phone;

    // Additional worker information fields
    private Integer age;
    private String block;

    // Getters and Setters
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getVillage() { return village; }
    public void setVillage(String village) { this.village = village; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    // Getters and setters for additional fields
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }

    public String getBlock() { return block; }
    public void setBlock(String block) { this.block = block; }
}