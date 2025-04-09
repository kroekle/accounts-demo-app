package com.styra.demo.accounts;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.styra.demo.accounts.mappers.AccountsMapper;
import com.styra.demo.accounts.model.Account;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;

// import io.swagger.v3.oas.annotations.Operation;
// import io.swagger.v3.oas.annotations.tags.Tag;
// import springfox.documentation.builders.PathSelectors;
// import springfox.documentation.builders.RequestHandlerSelectors;
// import springfox.documentation.spi.DocumentationType;
// import springfox.documentation.spring.web.plugins.Docket;

@RestController
@RequestMapping("/v1/g/accounts")
public class GlobalAccountsRestController {

    private static final Logger logger = LoggerFactory.getLogger(GlobalAccountsRestController.class);

    private AccountsMapper accountsMapper;
        // @Autowired
        // private RestTemplate restTemplate;
    
        // @Autowired
        // private UsAccounts accounts;
        // private String opaUrl = System.getenv("US_OPA_URL") == null ? "https://demo-opa-us-rmnuhnvfyq-uc.a.run.app"
        //         : System.getenv("US_OPA_URL");
    
        // @Bean
        // public Docket api() {
        //     return new Docket(DocumentationType.SWAGGER_2)
        //             .select()
        //             .apis(RequestHandlerSelectors.any())
        //             .paths(PathSelectors.any())
        //             .build();
        // }
    
    
        GlobalAccountsRestController(AccountsMapper accountsMapper) {
            this.accountsMapper = accountsMapper;
    }
    
    @GetMapping
    @SecurityRequirement(name = "role", scopes = {"international:admin", "international:viewer", "international:transfers"})
    @Operation(summary = "Get Accounts", description = "Get International based accounts by region")
    @Tag(name = "accounts", description = "Accounts API")
    @Tag(name = "international", description = "International API")
    List<Account> getAccountsByRegion(
        @RequestParam(required = false) String region,
        @RequestHeader(name = "x-max-balance", required = false) Long maxBalance,
        @RequestHeader(name = "x-blocked-regions", required = false) String blockedRegions){
        
        return accountsMapper.findByEverything(region, maxBalance, blockedRegions==null?null:blockedRegions.split(";"), false);
    }

    @GetMapping("/{id}")
    @SecurityRequirement(name = "role", scopes = {"international:admin", "international:viewer", "international:transfers"})
    @Operation(summary = "Get Account", description = "Get International based accounts by region")
    @Tag(name = "accounts", description = "Accounts API")
    @Tag(name = "international", description = "International API")
    Account getAccount(@PathVariable int id) {
        return accountsMapper.findById(id);
    }

    @DeleteMapping("/{id}")
    @SecurityRequirement(name = "role", scopes = {"international:admin"})
    @Operation(summary = "Inactivate Accounts", description = "Get International based accounts by region")
    @Tag(name = "accounts", description = "Accounts API")
    @Tag(name = "international", description = "International API")
    void closeAccount(@PathVariable int id)  {
        logger.info("Closing account: %v", id);
        accountsMapper.closeAccount(id);
    }

    @PatchMapping("/{id}")
    @SecurityRequirement(name = "role", scopes = {"international:admin"})
    @Operation(summary = "Re-activate Accounts", description = "Get International based accounts by region")
    @Tag(name = "accounts", description = "Accounts API")
    @Tag(name = "international", description = "International API")
    void reactivateAccount(@PathVariable int id)  {
        logger.info("Reactivating account: %v", id);
        accountsMapper.reactivateAccount(id);
    }

    @PostMapping("/txfr/{fromId}/{toId}/{amount}")
    @SecurityRequirement(name = "role", scopes = {"international:transfers"})
    @Operation(summary = "Transfer Funds")
    @Tag(name = "transfer", description = "Transfers API")
    @Tag(name = "accounts", description = "Accounts API")
    @Tag(name = "international", description = "International API")
    void transferFunds(@PathVariable("fromId") int from, @PathVariable("toId") int to,
            @PathVariable long amount, HttpServletRequest request)  {
        logger.info("Transferring %v from %v to %v", amount, from, to);
        accountsMapper.transferFunds(from, to, amount);
    }

    // private EnvoyResponse<AccountsCustom> callOpa(HttpServletRequest request) throws OPAException {

    //     OPAClient opa = new OPAClient(opaUrl);
    //     EnvoyResponse<AccountsCustom> resp = opa.evaluate("main/main", EnvoyRequest.parseRequest(request),
    //             new TypeReference<EnvoyResponse<AccountsCustom>>() {
    //             });

    //     if (!resp.isAllowed()) {
    //         throw new ForbiddenException("Get off my lawn, your not allowed here");
    //     }
    //     ;
    //     return resp;
    // }

}
