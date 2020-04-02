<template>
  <div class="container container-top">
    <b-container>
      <b-breadcrumb :items="breadcrumbs"></b-breadcrumb>
      <h1>Plants</h1>
      <div class="row">
        <div v-for="plant in plants" v-bind:key="plant.id" class="col-md-3 col-6 my-1">
          <div class="card h-100">
          <div class="card-body">
            <div class="card-title">Id: {{ plant.id }}</div>
            <div class="card-text">
              <p>Variety: {{ plant.variety }}</p>
              <p>State: {{ plant.state }}</p>
              <p>Owner: {{ plant.address }}</p>
            </div>
          </div>
          <div class="card-footer">
            <b-button @click="$router.push({ name: 'plant', params: { plantId: plant.id }})" variant="primary">View details</b-button>
          </div>
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

export default {
  name: 'home',
  data() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      plants: [],
      states: [ 'Propogated', 'Purchased', 'Dispatched', 'Stored', 'Planted'],
      breadcrumbs: [
        {
          text: "Home",
          to: { name: 'home' }
        },
        {
          text: "Plants",
          active: true
        }
      ]
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

      this.plants.push(p)
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
