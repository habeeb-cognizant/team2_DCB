package com.sprint2.model;

import java.time.LocalDate;

public record TextResponse(
    int responseId,
    int complaintId,
    int responderId,
    String message,
    LocalDate respondedAt
) implements Response {}
