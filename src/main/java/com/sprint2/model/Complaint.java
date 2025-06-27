package com.sprint2.model;

public class Complaint {
    private String description;
    private String status;

    public Complaint(String description, String status) {
        this.description = description;
        this.status = status;
    }

    public String getDescription() {
        return description;
    }

    public String getStatus() {
        return status;
    }
}
