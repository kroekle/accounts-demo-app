package com.styra.demo.accounts.mappers;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;

import com.styra.demo.accounts.model.Manager;

@Mapper
public interface ManagerMapper {

    @Select("SELECT manager_id, name, region FROM manager WHERE manager_id = #{id}")
    @Results(
        id = "managerResult",
        value = {
        @Result(property = "id", column = "manager_id"),
        @Result(property = "name", column = "name"),
        @Result(property = "region", column = "region")
    })
    Manager findById(@Param("id") String id);
}