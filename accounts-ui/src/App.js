import React, {useState, useEffect} from 'react';
import AccountList from './AccountList';
import User from './User';
import './App.css'
import myLogo from './images/logo.png'
import {SnackbarProvider, enqueueSnackbar, closeSnackbar} from 'notistack'
import {AuthzProvider} from '@styra/opa-react'
import {OPAClient} from '@styra/opa'
import Services from './services';
import IconButton from '@mui/material/IconButton';
import Menu from '@mui/material/Menu';
import MenuItem from '@mui/material/MenuItem';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import Slider from '@mui/material/Slider';
import Typography from '@mui/material/Typography';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import Switch from '@mui/material/Switch';
import FormControlLabel from '@mui/material/FormControlLabel';
import StateServices from './state';
import { use } from 'react';

const usRegions = [['x','All Regions'], ['EAST', "East"], ['WEST', "West"], ['NORTH', "North"], ['SOUTH', 'South']];
const gRegions = [['x','All Regions'], ['ASIA', 'Asia'], ['AFRICA','Africa'], ['AUSTRALIA','Australia'], ['EUROPE','Europe'], ['NA','North America (non US)'], ['SA','South America'], ['','']];

const u = new URL(window.location.toString());
u.pathname = "usopa";
const usSDK = new OPAClient(u.toString());
u.pathname = "gopa";
const gSDK = new OPAClient(u.toString());
const stateServices = new StateServices();

const marks = [
  {
    value: 0,
    label: 'RBAC',
  },
  {
    value: 10,
    label: 'ABAC',
  },
  {
    value: 20,
    label: 'ReBAC',
  },
  {
    value: 30,
    label: 'PBAC',
  },
];

function App() {
  const [token, setToken] = useState();
  const [error, setError] = useState();
  const [warnings, setWarnings] = useState("");
  const [regionLimit, setRegionLimit] = useState(false);
  const [balanceLimit, setBalanceLimit] = useState(false);
  const [usSvc, setUsSvc] = useState();
  const [gSvc, setGSvc] = useState();
  const [allAccounts, setAllAccounts] = useState([]);
  const [useAuthz, setUseAuthz] = useState(true);
  const [useBatch, setUseBatch] = useState(true);
  const [anchorEl, setAnchorEl] = useState(null);
  const [authz, setAuthz] = useState(0);
  const [officeHours, setOfficeHours] = useState(true);
  const [swipedIn, setSwipedIn] = useState(true);
  const [refreshAuthz, setRefreshAuthz] = useState(false);
  const menuOpen = Boolean(anchorEl);

  useEffect(() => {
    stateServices.setAttribute("officeHours", officeHours);
    setRefreshAuthz((a) => !a);
  }, [officeHours]);

  useEffect(() => {
    stateServices.setAttribute("swipedIn", swipedIn);
    setRefreshAuthz((a) => !a);
  }, [swipedIn]);

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
    if (token) {
      const label = marks.find(m => m.value === authz).label;
      setUsSvc(new Services("/v1/u/accounts", token, label))
      setGSvc(new Services("/v1/g/accounts", token, label))
    }
  }, [token, authz, refreshAuthz])

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


  const theme = createTheme({
    palette: {
      background: {
        paper: '#fff',
      },
      divider: '#e0e0e0',
      primary: {
        main: '#1976d2',
      },
    },
    components: {
      MuiSelect: {
        styleOverrides: {
          root: {
            borderRadius: '8px',
            backgroundColor: '#fff', // or use theme.palette.background.paper
            '& .MuiOutlinedInput-notchedOutline': {
              border: 'none',
            },
            '&:hover .MuiOutlinedInput-notchedOutline': {
              border: 'none',
            },
            '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
              border: 'none',
            },
          },
        },
      },
    },
  });

  return (
    <ThemeProvider theme={theme}>
      <div className="Header">
        <div className="Logo">
          <div>
            <img className="w2" src={myLogo} alt="Norsebank icon"/>
          </div>
          <div className="ml2">
            <h1>Norsebank</h1>
          </div>
        </div>
        <div className='flex'>
          <User setToken={setToken}/>
          <IconButton
            aria-label="more"
            id="long-button"
            aria-controls={menuOpen ? 'long-menu' : undefined}
            aria-expanded={menuOpen ? 'true' : undefined}
            aria-haspopup="true"
            onClick={(event) => {setAnchorEl(event.currentTarget);}}
          >
            <MoreVertIcon />
          </IconButton>
          <Menu 
            open={menuOpen} 
            onClose={() => setAnchorEl(null)}
            MenuListProps={{
              'aria-labelledby': 'long-button',
            }}
            anchorEl={anchorEl}>
              <MenuItem selected={useAuthz} onClick={() => {setUseAuthz(!useAuthz); setAnchorEl(null)}}>UI Authz</MenuItem>
              <MenuItem selected={useBatch} onClick={() => {setUseBatch(!useBatch); setAnchorEl(null)}}>Batch Authz</MenuItem>
          </Menu>
        </div>
        <SnackbarProvider/>

      </div>
      <div className="App">
        <div className="full-width">
            <AuthzProvider opaClient={usSDK} defaultPath={useAuthz?"policy/ui/check":"policy/ui/always"} retry={3} batch={useBatch}>
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
            <AuthzProvider opaClient={gSDK} defaultPath={useAuthz?"policy/ui/check":"policy/ui/always"} retry={3} batch={useBatch}>
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
      <div className="Footer"> 
        <div className="flex">
          <div className="ml2">
            <Typography id="discrete-slider-custom" gutterBottom>
              Authorization Model
            </Typography>
            <Slider
              value={authz}
              onChange={(event, newValue) => setAuthz(newValue)}
              getAriaValueText={(value) => `${value}`}
              aria-labelledby="discrete-slider-custom"
              step={null}
              valueLabelDisplay="off"
              min={0}
              max={30}
              marks={marks}
            />
          </div>
          {authz === 30 && (
            <div className="ml2 footer-switch">
  
            <FormControlLabel
              control={
                <Switch
                  checked={officeHours}
                  onChange={(event) => setOfficeHours(event.target.checked)}
                  inputProps={{ 'aria-label': 'During Office Hours' }}
                />}
            label="Durning Office Hours"
            labelPlacement="end"
            />
            <FormControlLabel
              control={
                <Switch
                  checked={swipedIn}
                  onChange={(event) => setSwipedIn(event.target.checked)}
                  inputProps={{ 'aria-label': 'Swiped In' }}
                />}
              label="Swiped In"
              labelPlacement="end"
              />
            </div>
          )}
          {/* <div className="ml2</div>">
            <h2>Powered by Styra DAS</h2>
          </div> */}
        </div>
      </div>
    </ThemeProvider>
  );
}

export default App;
