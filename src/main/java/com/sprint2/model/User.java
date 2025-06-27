package com.sprint2.model;

public record User(
    int userId,
    String fullName,
    String email,
    String password,
    String phoneNumber,
    String role,
    String department
) {}
