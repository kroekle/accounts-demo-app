package com.styra.demo.accounts.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class Manager {

    // public static Set<Region> US_REGIONS = Sets.newHashSet(Region.WEST, Region.EAST, Region.NORTH, Region.SOUTH);
    // public static Set<Region> GLOBAL_REGIONS = Sets.newHashSet(Region.NA, Region.SA, Region.AFRICA, Region.ASIA, Region.AUSTRALIA, Region.EUROPE);

    public enum Region {
        WEST, NORTH, SOUTH, EAST, ASIA, AFRICA, AUSTRALIA, EUROPE, NA, SA
    }

    @JsonProperty
    private String id;
    @JsonProperty
    private String name;
    @JsonProperty
    private Region region;
}