import React, {useState, useEffect} from 'react';
import AccountList from './AccountList';
import User from './User';
import './App.css'
import myLogo from './images/logo.png'
import {SnackbarProvider, enqueueSnackbar, closeSnackbar} from 'notistack'
import {AuthzProvider} from '@styra/opa-react'
import {OPAClient} from '@styra/opa'
import Services from './services';

const usRegions = [['x','All Regions'], ['EAST', "East"], ['WEST', "West"], ['NORTH', "North"], ['SOUTH', 'South']];
const gRegions = [['x','All Regions'], ['ASIA', 'Asia'], ['AFRICA','Africa'], ['AUSTRALIA','Australia'], ['EUROPE','Europe'], ['NA','North America (non US)'], ['SA','South America'], ['','']];

const u = new URL(window.location.toString());
u.pathname = "usopa";
const usSDK = new OPAClient(u.toString());
u.pathname = "gopa";
const gSDK = new OPAClient(u.toString());

function App() {
  const [token, setToken] = useState();
  const [error, setError] = useState();
  const [warnings, setWarnings] = useState("");
  const [regionLimit, setRegionLimit] = useState(false);
  const [balanceLimit, setBalanceLimit] = useState(false);
  const [usSvc, setUsSvc] = useState();
  const [gSvc, setGSvc] = useState();
  const [allAccounts, setAllAccounts] = useState([]);

  useEffect(() => {

    const doIt = async () =>{

      if (gSvc && usSvc) {

        await Promise.all([
          fetch(gSvc.listAll("x").path, gSvc.listAll("x").options).then(resp => resp.json()),
          fetch(usSvc.listAll("x").path, usSvc.listAll("x").options).then(resp => resp.json())
        ])
        .then(resp => {
          setAllAccounts([...new Set([...resp[0], ...resp[1]])]);
        })
      }
    }
    doIt();
  }, [usSvc, gSvc])

  useEffect(() => {
    setUsSvc(new Services("/v1/accounts", token))
    setGSvc(new Services("/v1/gaccounts", token))
  }, [token])

  useEffect(() => {
    if (error) {
      enqueueSnackbar("You don't have access to that, try another region", { variant: 'error' })
    }
  }, [error])

  useEffect(() => {
    if (balanceLimit) {
      enqueueSnackbar("Max Viewing Balance policy being enforced", { variant: 'info' })
    }
  }, [balanceLimit])

  useEffect(() => {
    if (regionLimit) {
      enqueueSnackbar("Region Limit policy being enforced", { variant: 'info' })
    }
  }, [regionLimit])

  useEffect(() => {
    closeSnackbar();
  }, [token])

  useEffect(() => {
    if (warnings.length > 0) {
      warnings.split(";").forEach(w => enqueueSnackbar(`Future: ${w}`, { variant: 'warning' }))
    }
  }, [warnings])


  return (
    <div>
      <div className="Header">
        <div className="Logo">
          <div>
            <img className="w2" src={myLogo} alt="Norsebank icon"/>
          </div>
          <div className="ml2">
            <h1>Norsebank</h1>
          </div>
        </div>
        <User setToken={setToken}/>
        <SnackbarProvider/>

      </div>
      <div className="App">
        <div className="full-width">
          {/* <AuthzProvider sdk={usSDK} defaultPath="policy/app/check/allowed"> */}
          <AuthzProvider opaClient={usSDK} defaultPath="policy/ui/check" retry={3} batch={false}>
            <AccountList 
              title="US Accounts" 
              svc={usSvc} 
              regions={usRegions} 
              setError={setError} 
              setBalanceLimit={setBalanceLimit} 
              setRegionLimit={setRegionLimit} 
              setWarnings={setWarnings} 
              allAccounts={allAccounts}
              />
          </AuthzProvider>
          <AuthzProvider opaClient={gSDK} defaultPath="policy/ui/check"  retry={3} batch={true}>
            <AccountList 
              title="Global Accounts" 
              svc={gSvc} 
              regions={gRegions} 
              setError={setError} 
              setBalanceLimit={setBalanceLimit} 
              setRegionLimit={setRegionLimit} 
              setWarnings={setWarnings} 
              allAccounts={allAccounts}
              />
          </AuthzProvider>
        </div>
      </div>
    </div>
  );
}

export default App;