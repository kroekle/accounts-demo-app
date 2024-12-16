package com.styra.demo.accounts.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Manager {

    @JsonProperty
    private String id;
    @JsonProperty
    private String name;
}