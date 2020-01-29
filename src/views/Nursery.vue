<template>
  <div class="container container-top">
    <b-container>
      <h1>Nursery</h1>
      <div class="row" v-if="nursery !== null">
        <div class="col">
          <div class="row">
            <h2>{{ nursery.name }}</h2>
          </div>
          <div class="row">
            <p>
              {{ nursery.description }}
            </p>
          </div>
          <div class="row">
            <b-list-group>
              <b-list-group-item v-for="plant in plants" v-bind:key="plant.id">
                Plant id: {{ plant.id }} - variety: {{ plant.variety }} - owner: {{ plant.address }} - status {{ plant.state }}
              </b-list-group-item>
            </b-list-group>
          </div>
          <div class="row mt-3">
            <b-button @click="propogatePlant" variant="primary">Propogate plant</b-button>
          </div>
        </div>
      </div>
    </b-container>
  </div>

</template>

<script>
import web3 from '../util/getWeb3'
import Supply from '../../build/contracts/Supply.json'
import TruffleContract from 'truffle-contract'
import { mkdir } from 'fs';

export default {
  name: 'home',
  data() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      nursery: null,
      plants: [],
      states: [ 'Propogated', 'Purchased', 'Dispatched', 'Received', 'Planted']
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
        contract.getNursery(this.$route.params.nurseryId).then((n) => {
          this.nursery = {
            id: n[0].toNumber(),
            name: n[1].toString(),
            lat: n[2].toNumber(),
            long: n[3].toNumber(),
            description: n[4].toString(),
            address: n[5]
          }
        })
      })

      this.supplyContract.deployed().then((contract) => {
        contract.getPlantCount().then((count) => {
          for (var i =0; i < count; i++)
          contract.getPlant(i).then((plant) => {
            this.addPlant(plant)
          })
        })
      })
    })
  },
  methods: {
    propogatePlant() {
      web3.eth.getAccounts().then((acc) => {
        this.defaultAccount = acc[0]
        web3.eth.defaultAccount = acc[0]

        this.supplyContract = TruffleContract(Supply)
        
        this.supplyContract.setProvider(this.w3.currentProvider)
        this.supplyContract.defaults({from: this.w3.eth.defaultAccount})

        this.supplyContract.deployed().then((contract) => {
          let date = (new Date()).getTime();
          let timestamp = Math.floor(date / 1000);
          contract.propogatePlant(timestamp)
        })
      })
    },
    addPlant: function(plant) {
      let p = {
        id: plant[0].toNumber(),
        state: this.states[plant[1].toNumber()],
        plantedDate: new Date(plant[2].toNumber() * 1000),
        lat: plant[3].toNumber(),
        long: plant[4].toNumber(),
        nursery: plant[5].toString(),
        variety: plant[6].toString(),
        address: plant[7].toString()
      }
      if (p.nursery === this.nursery.name) {
        this.plants.push(p)
      }
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
.card-header{
  background-color: rgba(0, 0, 0, 0.000000001);
  border-bottom: 0px;
}
</style>
