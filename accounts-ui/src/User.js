import { useEffect, useState } from "react";
import React from "react";

import { Select, MenuItem, Avatar } from "@mui/material";

const users = [
    {
      "id": "alice",
      "name": "Alice Doe",
      "initials": "AD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiTk9SVEgiLCJFVVJPUEUiXSwidGVycml0b3JpZXMiOlsidXMiLCJpbnRlcm5hdGlvbmFsIl0sImRlcGFydG1lbnQiOiJhY2NvdW50cyIsImxldmVsIjo1LCJlbXBsb3llZU51bWJlciI6IjEiLCJuYW1lIjoiQWxpY2UgRG9lIiwicm9sZXMiOlsiaW50ZXJuYXRpb25hbDp0cmFuc2ZlcnMiLCJpbnRlcm5hdGlvbmFsOmFkbWluIiwidXM6dHJhbnNmZXJzIiwidXM6YWRtaW4iXSwidGl0bGUiOiJHbG9iYWwgTWFuYWdlciIsInN1YiI6IjUwMDEifQ.2Vfo6SRlDdpIfQ31yIOK4Vq6NonIpuf-wk0XgUhjfCU"
    },
    {
      "id": "kurt",
      "name": "Kurt Doe",
      "initials": "KD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiV0VTVCJdLCJ0ZXJyaXRvcmllcyI6WyJ1cyJdLCJkZXBhcnRtZW50IjoiYWNjb3VudHMiLCJsZXZlbCI6MywiZW1wbG95ZWVOdW1iZXIiOiIyIiwibmFtZSI6Ikt1cnQgRG9lIiwicm9sZXMiOlsiaW50ZXJuYXRpb25hbDp2aWV3ZXIiLCJ1czp0cmFuc2ZlcnMiXSwidGl0bGUiOiJVUyBGdW5kcyBNYW5hZ2VyIiwic3ViIjoiNTAwMiJ9.NwpvfuaoiAg5pCRsiToQcZ0prLZebnVb_T7grpx-lrQ"  
    
    },
    {
      "id": "tim",
      "name": "Tim Doe",
      "initials": "TD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJidXNpbmVzc0NhdGVnb3J5IjoicHJpdmF0ZUJhbmtpbmciLCJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiRUFTVCJdLCJ0ZXJyaXRvcmllcyI6WyJ1cyJdLCJkZXBhcnRtZW50IjoiYWNjb3VudHMiLCJsZXZlbCI6MSwiZW1wbG95ZWVOdW1iZXIiOiIzIiwibmFtZSI6IlRpbSBEb2UiLCJyb2xlcyI6WyJpbnRlcm5hdGlvbmFsOnZpZXdlciIsInVzOmFkbWluIl0sInRpdGxlIjoiVVMgQWNjb3VudCBTdXBlcnZpc29yIiwic3ViIjoiNTAwMyJ9.lmNYphd9uKevbAUZpubvO7zSWmmiWNh9kIyvLy2vfe0"
    },
    {
      "id": "sue",
      "name": "Sue Doe",
      "initials": "SD",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Ijoibm9yc2ViYW5rIiwiaG9tZVJlZ2lvbnMiOlsiQVNJQSJdLCJ0ZXJyaXRvcmllcyI6WyJpbnRlcm5hdGlvbmFsIl0sImRlcGFydG1lbnQiOiJhY2NvdW50cyIsImVtcGxveWVlTnVtYmVyIjoiNCIsImxldmVsIjozLCJuYW1lIjoiU3VlIERvZSIsInJvbGVzIjpbImludGVybmF0aW9uYWw6dmlld2VyIiwidXM6dmlld2VyIl0sInRpdGxlIjoiR2xvYmFsIFN1cHBvcnQgU3BlY2lhbGlzdCIsInN1YiI6IjUwMDQifQ.UTAPdDQJYxT8QByrwd7WMEkGyCzqGl5lLG_P_vTfXHk"
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