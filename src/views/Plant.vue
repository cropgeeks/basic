<template>
  <div class="container container-top">
    <b-container>
      <div class="row" v-if="plant !== null">
        <div class="col">
          <h1>Plant Id: {{ plant.id }}</h1>
          <div class="row">
            <h4>Variety: {{ plant.variety }}</h4>
          </div>
          <div class="row" v-if="propogated !== null">
            <b-table small bordered caption-top caption="Propogated plants" :items="propogated"></b-table>
          </div>
          <div class="row" v-if="ordered !== null">
            <b-table small bordered caption-top caption="Assigned to order" :items="ordered"></b-table>
          </div>
          <div class="row" v-if="purchased !== null">
            <b-table small bordered caption-top caption="Purchased by farmer" :items="purchased"></b-table>
          </div>
          <div class="row" v-if="dispatched !== null">
            <b-table small bordered caption-top caption="Dispatched by nursery" :items="dispatched"></b-table>
          </div>
          <div class="row" v-if="stored !== null">
            <b-table small bordered caption-top caption="Stored by farmer" :items="stored"></b-table>
          </div>
          <div class="row" v-if="planted !== null">
            <b-table small bordered caption-top caption="Planted by farmer" :items="planted"></b-table>
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
      states: [ 'Propogated', 'Purchased', 'Dispatched', 'Stored', 'Planted'],
      propogated: null,
      ordered: null,
      purchased: null,
      dispatched: null,
      stored: null,
      planted: null
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
            plant_owner: returnValues.ownerAddress,
            nursery: returnValues.name,
            date: new Date(returnValues.date * 1000),
            latitude: returnValues.lat,
            longitude: returnValues.long
          }]
        })
      })

      this.supplyContract.deployed().then((contract) => {
        contract.getPastEvents('AssignedToOrder', {
          filter: {plantId: this.$route.params.plantId},
          fromBlock: 0,
          toBlock: 'latest'
        })
        .then((events) => {
          const returnValues = events[0].returnValues;
          this.ordered = [{
            plant_id: returnValues.plantId,
            order_id: returnValues.orderId,
            nursery: returnValues.nurseryName,
            purchasing_farm: returnValues.farmName
          }]
        })
      })

      this.supplyContract.deployed().then((contract) => {
        contract.getPastEvents('PurchasedByFarmer', {
          filter: {plantId: this.$route.params.plantId},
          fromBlock: 0,
          toBlock: 'latest'
        })
        .then((events) => {
          const returnValues = events[0].returnValues;
          this.purchased = [{
            plant_id: returnValues.plantId,
            order_id: returnValues.orderId,
            nursery: returnValues.nurseryName,
            purchasing_farm: returnValues.farmName,
            purchase_date: new Date(returnValues.date * 1000),
            latitude: returnValues.lat,
            longitude: returnValues.long
          }]
        })
      })

      this.supplyContract.deployed().then((contract) => {
        contract.getPastEvents('DispatchedByNursery', {
          filter: {plantId: this.$route.params.plantId},
          fromBlock: 0,
          toBlock: 'latest'
        })
        .then((events) => {
          const returnValues = events[0].returnValues;
          this.dispatched = [{
            plant_id: returnValues.plantId,
            order_id: returnValues.orderId,
            nursery: returnValues.nurseryName,
            purchasing_farm: returnValues.farmName,
            purchase_date: new Date(returnValues.date * 1000),
            latitude: returnValues.lat,
            longitude: returnValues.long
          }]
        })
      })

      this.supplyContract.deployed().then((contract) => {
        contract.getPastEvents('StoredByFarmer', {
          filter: {plantId: this.$route.params.plantId},
          fromBlock: 0,
          toBlock: 'latest'
        })
        .then((events) => {
          const returnValues = events[0].returnValues;
          this.stored = [{
            plant_id: returnValues.plantId,
            plant_owner: returnValues.plantOwner,
            storage_date: new Date(returnValues.date * 1000),
            store_name: returnValues.storeName,
            temperature: returnValues.storeTemp,
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
