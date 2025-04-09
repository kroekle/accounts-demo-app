package com.styra.demo.accounts;

import javax.sql.DataSource;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.styra.demo.accounts.mappers")
public class PersistenceConfig {

    @Bean
    DataSource dataSource() {
        return DataSourceBuilder.create()
                .driverClassName("org.postgresql.Driver")
                .url("jdbc:postgresql://postgres:5432/testdb")
                .username("sa")
                .password("sa")
                .build();
    }
}