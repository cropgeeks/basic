<template>
  <div id="app">
    <b-navbar toggleable="lg" type="light" variant="success">
      <b-navbar-brand>
        <router-link to="/">
          <img src="./assets/basic.svg" height="40px" alt="Basic">
        </router-link>
      </b-navbar-brand>

      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>
      <b-collapse id="nav-collapse" is-nav>
        <b-navbar-nav>
          <b-nav-item to="/nurseries">Nurseries</b-nav-item>
          <b-nav-item to="/farms">Farms</b-nav-item>
          <b-nav-item to="/packhouses">Packhouses</b-nav-item>
          <b-nav-item to="/plants">Plants</b-nav-item>
        </b-navbar-nav>

        <b-navbar-nav class="ml-auto">
          <b-nav-item to="/admin" v-if="isAdmin">Admin</b-nav-item>
          <b-nav-item to="/about">About</b-nav-item>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
    <router-view :key="$route.path"/>
  </div>
</template>

<script>
import web3 from './util/getWeb3'
import Supply from '../build/contracts/Supply.json'
import TruffleContract from 'truffle-contract'

export default {
  name: 'app',
   data() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      isAdmin: false
    }
  },
  mounted() {
    web3.eth.getAccounts().then((acc) => {
      this.defaultAccount = acc[0]
      web3.eth.defaultAccount = acc[0]

      this.supplyContract = TruffleContract(Supply)
      
      this.supplyContract.setProvider(this.w3.currentProvider)
      this.supplyContract.defaults({from: this.w3.eth.defaultAccount})
      this.supplyContract.deployed().then((contract) => {
        contract.isOwner().then((owner) => {
          this.isAdmin = owner;
        })
      })
    })
  },
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  min-height: 100vh;
}

#nav {
  padding: 30px;
}
</style>
