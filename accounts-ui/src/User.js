import { useEffect, useState } from "react";
import React from "react";

import { Select, MenuItem, Avatar } from "@mui/material";

const users = [
    {
      "id": "alice",
      "name": "Alice Doe",
      "initials": "AD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoicHJpdmF0ZUJhbmtpbmciLCJjb21wYW55Ijoibm9yc2ViYW5rIiwiZGVwYXJ0bWVudCI6IndlYWx0aE1hbmFnZW1lbnQiLCJlbXBsb3llZU51bWJlciI6IjEiLCJuYW1lIjoiQWxpY2UgRG9lIiwicm9sZXMiOlsiaW50ZXJuYXRpb25hbDp0cmFuc2ZlcnMiLCJpbnRlcm5hdGlvbmFsOmFkbWluIiwidXM6dHJhbnNmZXJzIiwidXM6YWRtaW4iXSwidGl0bGUiOiJHbG9iYWwgTWFuYWdlciIsInN1YiI6IjUwMDEifQ.E1j9r-EoNO627Pk5HfTfHLvlWSRzqZxL8isWjiRxpqk"
    },
    {
      "id": "kurt",
      "name": "Kurt Doe",
      "initials": "KD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoicHJpdmF0ZUJhbmtpbmciLCJjb21wYW55Ijoibm9yc2ViYW5rIiwiZGVwYXJ0bWVudCI6IndlYWx0aE1hbmFnZW1lbnQiLCJlbXBsb3llZU51bWJlciI6IjIiLCJuYW1lIjoiS3VydCBEb2UiLCJyb2xlcyI6WyJpbnRlcm5hdGlvbmFsOnZpZXdlciIsInVzOnRyYW5zZmVycyJdLCJ0aXRsZSI6IlVTIEZ1bmRzIE1hbmFnZXIiLCJzdWIiOiI1MDAyIn0.tiNN2NGxdPNxZJ1hcSu1wO_mMSJyND6Q8T0b4BuqcIo"  
    
    },
    {
      "id": "tim",
      "name": "Tim Doe",
      "initials": "TD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoicHJpdmF0ZUJhbmtpbmciLCJjb21wYW55Ijoibm9yc2ViYW5rIiwiZGVwYXJ0bWVudCI6IndlYWx0aE1hbmFnZW1lbnQiLCJlbXBsb3llZU51bWJlciI6IjMiLCJuYW1lIjoiVGltIERvZSIsInJvbGVzIjpbImludGVybmF0aW9uYWw6dmlld2VyIiwidXM6YWRtaW4iXSwidGl0bGUiOiJVUyBBY2NvdW50IFN1cGVydmlzb3IiLCJzdWIiOiI1MDAzIn0.4ZbodP2sbemtZ1Rb78ZHfQmX7FvxJN9kUJO3fwKwe9k"
    },
    {
      "id": "sue",
      "name": "Sue Doe",
      "initials": "SD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoicHJpdmF0ZUJhbmtpbmciLCJjb21wYW55Ijoibm9yc2ViYW5rIiwiZGVwYXJ0bWVudCI6ImN1c3RvbWVyU2VydmljZSIsImVtcGxveWVlTnVtYmVyIjoiNCIsIm5hbWUiOiJTdWUgRG9lIiwicm9sZXMiOlsiaW50ZXJuYXRpb25hbDp2aWV3ZXIiLCJ1czp2aWV3ZXIiXSwidGl0bGUiOiJHbG9iYWwgU3VwcG9ydCBTcGVjaWFsaXN0Iiwic3ViIjoiNTAwNCJ9.nl9spo7UcETOYb3qPb3jNH8UnUPfOddJ7-PXhWTHoZs"
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