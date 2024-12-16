package com.styra.demo.accounts.model;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Account {

    public enum Status {
        ACTIVE, INACTIVE
    }

    public enum Region {
        WEST, NORTH, SOUTH, EAST, ASIA, AFRICA, AUSTRALIA, EUROPE, NA, SA
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
    @JsonProperty
    private Region region;
}