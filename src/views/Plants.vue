<template>
  <b-container class="container-top">
    <b-breadcrumb :items="breadcrumbs"></b-breadcrumb>
    <h1>Plants</h1>
    <div class="row">
      <b-table class="mb-0" striped hover small bordered :items="plants" :per-page="perPage" :current-page="currentPage" selectable  @row-clicked="selectRow">
      </b-table>
      <b-pagination
        v-if="plants.length > 0"
        v-model="currentPage"
        :total-rows="plants.length"
        :per-page="perPage"
        size="sm"
      ></b-pagination>
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
      plants: [],
      states: [ 'Propogated', 'Purchased', 'Dispatched', 'Stored', 'Planted'],
      perPage: 10,
      currentPage: 1,
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
    },
    selectRow(plant) {
      this.$router.push({ name: 'plant', params: { plantId: plant.id }})
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
