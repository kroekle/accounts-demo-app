package com.styra.demo.accounts.mappers;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.ResultMap;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.SelectProvider;
import org.apache.ibatis.annotations.Update;

import com.styra.demo.accounts.model.Account;

@Mapper
public interface AccountsMapper {

    @Select("SELECT account_id, holder_name, balance, account_status, m.manager_id, name, region FROM account JOIN manager m using (manager_id) WHERE account_id = #{id} order by account_id")
    @Results(id = "accountResult", value = {
        @Result(property = "id", column = "account_id"),
        @Result(property = "holderName", column = "holder_name"),
        @Result(property = "balance", column = "balance"),
        @Result(property = "status", column = "account_status"),
        @Result(property = "manager.id", column = "manager_id"),
        @Result(property = "manager.name", column = "name"),
        @Result(property = "region", column = "region")
    })
    Account findById(@Param("id") int id);

    @SelectProvider(type = AccountsMapper.class, method = "generateSelect")
    @ResultMap("accountResult")
    List<Account> findByEverything(
        @Param("region") String region,
        @Param("maxBalance") Long maxBalance,
        @Param("blockedRegions") String[] blockedRegions,
        @Param("us") boolean us);

    static String generateSelect(Map<String, Object> params) {
        StringBuilder sb = new StringBuilder(
                "SELECT account_id, holder_name, balance, account_status, m.manager_id, name, region "
                        + "FROM account "
                        + "JOIN manager m using (manager_id) ");

        if (params.values().stream().anyMatch(v -> v != null))
            sb.append("WHERE us = " + params.get("us"));

        if (params.get("maxBalance") != null) {
            
            sb.append(" AND balance <=  " + params.get("maxBalance"));
        }

        if (params.containsKey("region") && params.get("region") != null) {

            sb.append(" AND region = '" + params.get("region") + "'");
        }
        if (params.get("blockedRegions") != null) {

            sb.append(" AND region NOT IN ('" + String.join("', '", (String[]) params.get("blockedRegions")) + "')");
        }
        return sb.toString();
    }

    @Update("UPDATE account SET account_status = 'INACTIVE' WHERE account_id = #{id}")
    void closeAccount(@Param("id") int id);

    @Update("UPDATE account SET account_status = 'ACTIVE' WHERE account_id = #{id}")
    void reactivateAccount(@Param("id") int id);

    @Update("UPDATE account SET balance = balance - #{amount} WHERE account_id = #{fromAccount}; UPDATE account SET balance = balance + #{amount} WHERE account_id = #{toAccount};")
    void transferFunds(@Param("fromAccount") int fromId, @Param("toAccount") int toId, @Param("amount") Long amount);

}