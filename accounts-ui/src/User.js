import { useEffect, useState } from "react";
import React from "react";

import { Select, MenuItem, Avatar } from "@mui/material";

const users = [
    {
      "id": "alice",
      "name": "Alice Doe",
      "initials": "AD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiV0VTVCIsIkVVUk9QRSJdLCJ0ZXJyaXRvcmllcyI6WyJ1cyIsImludGVybmF0aW9uYWwiXSwiZGVwYXJ0bWVudCI6ImFjY291bnRzIiwibGV2ZWwiOjUsImVtcGxveWVlTnVtYmVyIjoiMSIsIm5hbWUiOiJBbGljZSBEb2UiLCJyb2xlcyI6WyJpbnRlcm5hdGlvbmFsOnRyYW5zZmVycyIsImludGVybmF0aW9uYWw6YWRtaW4iLCJ1czp0cmFuc2ZlcnMiLCJ1czphZG1pbiJdLCJ0aXRsZSI6Ikdsb2JhbCBNYW5hZ2VyIiwic3ViIjoiNTAwMSJ9.5m90nTyyYpwPxoh84XOgkaQFaOsiaOZqF4iMVOLDaXA"
    },
    {
      "id": "kurt",
      "name": "Kurt Doe",
      "initials": "KD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiTk9SVEgiXSwidGVycml0b3JpZXMiOlsidXMiXSwiZGVwYXJ0bWVudCI6ImFjY291bnRzIiwibGV2ZWwiOjMsImVtcGxveWVlTnVtYmVyIjoiMiIsIm5hbWUiOiJLdXJ0IERvZSIsInJvbGVzIjpbImludGVybmF0aW9uYWw6dmlld2VyIiwidXM6dHJhbnNmZXJzIiwidXM6YWRtaW4iXSwidGl0bGUiOiJVUyBGdW5kcyBNYW5hZ2VyIiwic3ViIjoiNTAwMiJ9.X1YbOI7wXpv0RidVfS1vw7vLWDb-xJC6BbE0hMpeiLU"  
    
    },
    {
      "id": "tim",
      "name": "Tim Doe",
      "initials": "TD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoicHJpdmF0ZUJhbmtpbmciLCJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiRUFTVCJdLCJ0ZXJyaXRvcmllcyI6WyJ1cyJdLCJkZXBhcnRtZW50IjoiYWNjb3VudHMiLCJsZXZlbCI6MSwiZW1wbG95ZWVOdW1iZXIiOiI0IiwibmFtZSI6IlRpbSBEb2UiLCJyb2xlcyI6WyJpbnRlcm5hdGlvbmFsOnZpZXdlciIsInVzOmFkbWluIl0sInRpdGxlIjoiVVMgQWNjb3VudCBTdXBlcnZpc29yIiwic3ViIjoiNTAwNCJ9.2UZjKKeWo74lOHLKZBZuWvCwQxgUn4T05mEoxXtrfVw"
    },
    {
      "id": "sue",
      "name": "Sue Doe",
      "initials": "SD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiQVNJQSJdLCJ0ZXJyaXRvcmllcyI6WyJpbnRlcm5hdGlvbmFsIl0sImRlcGFydG1lbnQiOiJhY2NvdW50cyIsImVtcGxveWVlTnVtYmVyIjoiNSIsImxldmVsIjozLCJuYW1lIjoiU3VlIERvZSIsInJvbGVzIjpbImludGVybmF0aW9uYWw6dmlld2VyIiwidXM6dmlld2VyIl0sInRpdGxlIjoiR2xvYmFsIFN1cHBvcnQgU3BlY2lhbGlzdCIsInN1YiI6IjUwMDUifQ.JRk8AldU8BvdG6c6Pr6p8HpUcx7P68awsivShDIPRvg"
    }
  ]

function User ({setToken}) {

    const [user, setUser] = useState("alice");
    useEffect(() => {
        setToken(users.find(u => u.id === user).token);
    }, [user, setToken]);
    return (
      <div className="user">
        <Select value={user} onChange={(event) => setUser(event.target.value)}>
          {users.map((u) => (
            
            <MenuItem key={u.id} value={u.id}>
              <div className="login">
                <Avatar>{u.initials}</Avatar>
                <div className="login-name">{u.name}</div>
              </div>
            </MenuItem>
          ))}
        </Select>
      </div>
    )
  }

  export default User;