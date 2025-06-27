package com.sprint2.model;

import java.time.LocalDate;

public record FileResponse(
    int responseId,
    int complaintId,
    int responderId,
    String fileUrl,
    LocalDate respondedAt
) implements Response {}
