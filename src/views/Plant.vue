<template>
  <div class="container container-top">
    <b-container>
      <h1>Plant Id: {{ plant.id }}</h1>
      <div class="row" v-if="plant !== null">
        <div class="col">
          <div class="row">
            <h4>Variety: {{ plant.variety }}</h4>
          </div>
          <div class="row" v-if="propogated !== null">
            <h4>Propogated</h4>
            <b-table :items="propogated"></b-table>
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
      plant: null,
      states: [ 'Propogated', 'Purchased', 'Dispatched', 'Received', 'Planted'],
      propogated: null
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
        contract.getPlant(this.$route.params.plantId).then((p) => {
          this.plant = {
            id: p[0].toNumber(),
            state: this.states[p[1].toNumber()],
            plantedDate: new Date(p[2].toNumber() * 1000),
            lat: p[3].toNumber(),
            long: p[4].toNumber(),
            nursery: p[5].toString(),
            variety: p[6].toString(),
            address: p[7].toString()
          }
        })
      })

      this.supplyContract.deployed().then((contract) => {
        contract.getPastEvents('PropogatedByNursery', {
          filter: {plantId: this.$route.params.plantId},
          fromBlock: 0,
          toBlock: 'latest'
        })
        .then((events) => {
          const returnValues = events[0].returnValues;
          this.propogated = [{
            plant_id: returnValues.plantId,
            plant_owner: returnValues.plantOwner,
            nursery: returnValues.nurseryName,
            date: new Date(returnValues.date * 1000),
            latitude: returnValues.lat,
            longitude: returnValues.long
          }]
        })
      })
    })
  },
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
