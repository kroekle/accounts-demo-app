package com.styra.demo.accounts.model;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Account {

    public enum Status {
        ACTIVE, INACTIVE
    }

    @JsonProperty
    private String id;
    @JsonProperty
    private String holderName;
    @JsonProperty
    private BigDecimal balance; 
    @JsonProperty
    private Manager manager;
    @JsonProperty
    private Status status;
}