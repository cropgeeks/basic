<template>
  <b-container class="container-top">
    <h1>Admin</h1>
    <div class="row" v-if="isAdmin">
      <b-card-group deck>
        <b-card
          title="Nursery"
          img-src="~@/assets/plantnursery.jpg"
          img-alt="plant nursery"
        >
          <b-button to="/admin/nursery" varaint="primary">Add nursery</b-button>
        </b-card>
        <b-card
          title="Farm"
          img-src="~@/assets/raspberries-small.jpg"
          img-alt="farm"
        >
          <b-button to="/admin/farm" varaint="primary">Add farm</b-button>
        </b-card>
        <b-card
          title="Packhouse"
          img-src="~@/assets/raspberry-punnets.jpg"
          img-alt="packhouse"
        >
          <b-button to="/admin/packhouse" varaint="primary">Add packhouse</b-button>
        </b-card>
        <b-card
          title="Roles"
          img-src="~@/assets/role-icon.png"
          img-alt="roles"
        >
          <b-button to="/admin/roles" varaint="primary">Manage roles</b-button>
        </b-card>
      </b-card-group>
    </div>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'
import Supply from '../../build/contracts/Supply.json'
import TruffleContract from 'truffle-contract'

export default {
  name: 'home',
  data() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      isAdmin: false,
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
        contract.isOwner().then((isOwner) => {
          this.isAdmin = isOwner;
        })
      })
    })
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
</style>
