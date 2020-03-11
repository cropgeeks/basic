<template>
  <b-container class="container-top">
    <h1>Add Nursery</h1>
    <div class="row" v-if="isAdmin">
      <div class="col">
        <b-form>
          <b-form-group label="Owner" label-for="nursery-owner" label-align="left">
            <b-input id="nursery-owner" type="text" size="sm" placeholder="Nursery owner" v-model="nurseryOwner"/>
          </b-form-group>
          <b-form-group label="Name" label-for="nursery-name" label-align="left">
            <b-input id="nursery-name" size="sm" placeholder="Name" v-model="nurseryName"/>
          </b-form-group>
          <b-form-group label="Latitude" label-for="nursery-lat" label-align="left">
            <b-input id="nursery-lat" size="sm" placeholder="0" type="number" step="0.01" min="-90" max="90" v-model="nurseryLat"/>
          </b-form-group>
          <b-form-group label="Longitude" label-for="nursery-long" label-align="left">
            <b-input id="nursery-long" size="sm" placeholder="0" type="number" step="0.01" min="-180" max="180" v-model="nurseryLong"/>
          </b-form-group>
          <b-form-group label="Description" label-for="nursery-desc" label-align="left">
            <b-input id="nursery-description" type="text" size="sm" placeholder="Nursery description" v-model="nurseryDesc"/>
          </b-form-group>
          <button class="btn btn-primary float-left" type="submit">Add nursery</button>
        </b-form>
      </div>
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
      nurseryName: null,
      nurseryLat: null,
      nurseryLong: null,
      nurseryDesc: null,
      nurseryOwner: null
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
  },
  methods: {
    propogatePlant() {
      this.supplyContract.deployed().then((contract) => {
        let date = (new Date()).getTime();
        let timestamp = Math.floor(date / 1000);
        contract.propogatePlant(timestamp);
      })
    }
    // addNursery: function(nursery) {
    //   let n = {
    //     id: nursery[0].toNumber(),
    //     name: nursery[1].toString(),
    //     lat: nursery[2].toNumber(),
    //     long: nursery[3].toNumber(),
    //     description: nursery[4].toString(),
    //   }

    //   this.nurseries.push(n);
    // }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
</style>
