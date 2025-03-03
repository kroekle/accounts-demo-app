package main

import (
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"database/sql"

	_ "github.com/lib/pq"
)

var (
	jwtTokens = []string{
		"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiV0VTVCIsIkVVUk9QRSJdLCJ0ZXJyaXRvcmllcyI6WyJ1cyIsImludGVybmF0aW9uYWwiXSwiZGVwYXJ0bWVudCI6ImFjY291bnRzIiwibGV2ZWwiOjUsImVtcGxveWVlTnVtYmVyIjoiMSIsIm5hbWUiOiJBbGljZSBEb2UiLCJyb2xlcyI6WyJpbnRlcm5hdGlvbmFsOnRyYW5zZmVycyIsImludGVybmF0aW9uYWw6YWRtaW4iLCJ1czp0cmFuc2ZlcnMiLCJ1czphZG1pbiJdLCJ0aXRsZSI6Ikdsb2JhbCBNYW5hZ2VyIiwic3ViIjoiNTAwMSJ9.5m90nTyyYpwPxoh84XOgkaQFaOsiaOZqF4iMVOLDaXA",
		"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiTk9SVEgiXSwidGVycml0b3JpZXMiOlsidXMiXSwiZGVwYXJ0bWVudCI6ImFjY291bnRzIiwibGV2ZWwiOjMsImVtcGxveWVlTnVtYmVyIjoiMiIsIm5hbWUiOiJLdXJ0IERvZSIsInJvbGVzIjpbImludGVybmF0aW9uYWw6dmlld2VyIiwidXM6dHJhbnNmZXJzIiwidXM6YWRtaW4iXSwidGl0bGUiOiJVUyBGdW5kcyBNYW5hZ2VyIiwic3ViIjoiNTAwMiJ9.X1YbOI7wXpv0RidVfS1vw7vLWDb-xJC6BbE0hMpeiLU",
		"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoicHJpdmF0ZUJhbmtpbmciLCJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiRUFTVCJdLCJ0ZXJyaXRvcmllcyI6WyJ1cyJdLCJkZXBhcnRtZW50IjoiYWNjb3VudHMiLCJsZXZlbCI6MSwiZW1wbG95ZWVOdW1iZXIiOiI0IiwibmFtZSI6IlRpbSBEb2UiLCJyb2xlcyI6WyJpbnRlcm5hdGlvbmFsOnZpZXdlciIsInVzOmFkbWluIl0sInRpdGxlIjoiVVMgQWNjb3VudCBTdXBlcnZpc29yIiwic3ViIjoiNTAwNCJ9.2UZjKKeWo74lOHLKZBZuWvCwQxgUn4T05mEoxXtrfVw",
		"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiQVNJQSJdLCJ0ZXJyaXRvcmllcyI6WyJpbnRlcm5hdGlvbmFsIl0sImRlcGFydG1lbnQiOiJhY2NvdW50cyIsImVtcGxveWVlTnVtYmVyIjoiNSIsImxldmVsIjozLCJuYW1lIjoiU3VlIERvZSIsInJvbGVzIjpbImludGVybmF0aW9uYWw6dmlld2VyIiwidXM6dmlld2VyIl0sInRpdGxlIjoiR2xvYmFsIFN1cHBvcnQgU3BlY2lhbGlzdCIsInN1YiI6IjUwMDUifQ.JRk8AldU8BvdG6c6Pr6p8HpUcx7P68awsivShDIPRvg",
	}

	authzTypes = []string{
		"RBAC",
		"ABAC",
		"PBAC",
		"ReBAC",
	}
)

type Account struct {
	ID      string  `json:"id"`
	Active  bool    `json:"active"`
	Balance float64 `json:"balance"`
	Region  string  `json:"region"`
}

func (a Account) getBaseUrl() string {

	switch a.Region {
	case "WEST", "NORTH", "SOUTH", "EAST":
		return "http://us-accounts/v1/u/accounts"
	}
	return "http://global-accounts/v1/g/accounts"
}

type Accounts struct {
	Accounts []Account
}

func (a Accounts) addHeaders(req *http.Request) {
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+jwtTokens[rand.Intn(len(jwtTokens))])
	req.Header.Set("Authz-Type", authzTypes[rand.Intn(len(authzTypes))])
}

func (a Accounts) getRandomClose() *http.Request {
	activeAccounts := []Account{}
	for _, account := range a.Accounts {
		if account.Active {
			activeAccounts = append(activeAccounts, account)
		}
	}

	if len(activeAccounts) == 0 {
		return nil
	}

	randomAccount := activeAccounts[rand.Intn(len(activeAccounts))]
	url := fmt.Sprintf("%s/%s", randomAccount.getBaseUrl(), randomAccount.ID)
	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		fmt.Printf("Error creating request: %v\n", err)
		return nil
	}

	a.addHeaders(req)

	return req
}

func (a Accounts) getRandomReactivate() *http.Request {
	inactiveAccounts := []Account{}
	for _, account := range a.Accounts {
		if !account.Active {
			inactiveAccounts = append(inactiveAccounts, account)
		}
	}

	if len(inactiveAccounts) == 0 {
		return nil
	}

	randomAccount := inactiveAccounts[rand.Intn(len(inactiveAccounts))]
	url := fmt.Sprintf("%s/%s", randomAccount.getBaseUrl(), randomAccount.ID)
	req, err := http.NewRequest("PATCH", url, nil)
	if err != nil {
		fmt.Printf("Error creating request: %v\n", err)
		return nil
	}

	a.addHeaders(req)
	return req
}

func (a Accounts) getRandomTransfer() *http.Request {
	activeAccounts := []Account{}
	for _, account := range a.Accounts {
		if account.Active {
			activeAccounts = append(activeAccounts, account)
		}
	}

	if len(activeAccounts) == 0 {
		return nil
	}

	randomAccount := activeAccounts[rand.Intn(len(activeAccounts))]
	randomToAccount := a.Accounts[rand.Intn(len(a.Accounts))]
	amount := rand.Float64() * randomAccount.Balance
	url := fmt.Sprintf("%s/txfr/%s/%s/%.0f", randomAccount.getBaseUrl(), randomAccount.ID, randomToAccount.ID, amount)
	req, err := http.NewRequest("POST", url, nil)
	if err != nil {
		fmt.Printf("Error creating request: %v\n", err)
		return nil
	}

	a.addHeaders(req)
	return req
}

func main() {

	for {
		// Random delay between 1 and 10 seconds
		delay := time.Duration(rand.Intn(10)+1) * time.Second
		time.Sleep(delay)

		makeRequests()
	}
}

func getAccountsFromDB() (Accounts, error) {
	db, err := sql.Open("postgres", "postgres://sa:sa@postgres:5432/testdb?sslmode=disable")

	if err != nil {
		return Accounts{}, fmt.Errorf("error connecting to the database: %v", err)
	}
	defer db.Close()

	rows, err := db.Query("SELECT account_id, case account_status when 'ACTIVE' then true else false end, balance, region FROM account where account_id > 12")
	if err != nil {
		return Accounts{}, fmt.Errorf("error querying the database: %v", err)
	}
	defer rows.Close()

	var accounts []Account
	for rows.Next() {
		var account Account
		if err := rows.Scan(&account.ID, &account.Active, &account.Balance, &account.Region); err != nil {
			return Accounts{}, fmt.Errorf("error scanning row: %v", err)
		}
		accounts = append(accounts, account)
	}

	if err := rows.Err(); err != nil {
		return Accounts{}, fmt.Errorf("error with rows: %v", err)
	}

	return Accounts{Accounts: accounts}, nil
}

func makeRequests() {

	accounts, err := getAccountsFromDB()
	if err != nil {
		fmt.Printf("Error getting accounts from database: %v\n", err)
		return
	}

	client := &http.Client{}

	for i := 0; i < 6; i++ {
		doRequest(client, accounts.getRandomTransfer())
		doRequest(client, accounts.getRandomClose())
		doRequest(client, accounts.getRandomReactivate())
	}
}

func doRequest(client *http.Client, req *http.Request) {

	if req == nil {
		// fmt.Println("No accounts available")
		return
	}

	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("Error making request: %v\n", err)
		return
	}
	defer resp.Body.Close()

	fmt.Printf("Request to %s:%s returned status %d\n", req.Method, req.URL, resp.StatusCode)
}
