function Services(baseUrl, token) {
    this.baseUrl = baseUrl;
    this.token = token;

    this.listAll = (region) => {
        let queryString = region==='x'?'':`?region=${region}`;

        return {
            "path": baseUrl + queryString,
            "options": {
                "method": "GET",
                "headers": {
                  "authorization": `Bearer ${token}`
                }
            }
        }
    }

    this.closeAccount = (accountId) => {
        return {
            "path": baseUrl + "/" + accountId,
            "options": {
                "method": "DELETE",
                "headers": {
                  "authorization": `Bearer ${token}`
                }
            }
        }
    }

    this.reopenAccount = (accountId) => {
        return {
            "path": baseUrl + "/" + accountId,
            "options": {
                "method": "PATCH",
                "headers": {
                  "authorization": `Bearer ${token}`
                }
            }
        }
    }

    this.transferFunds = (fromAccount, toAccount, amount) => {
        return {
            "path": `${baseUrl}/txfr/${fromAccount}/${toAccount}/${amount}`,
            "options": {
                "method": "POST",
                "headers": {
                  "authorization": `Bearer ${token}`
                }
            }
        }
    }

}

export default Services;