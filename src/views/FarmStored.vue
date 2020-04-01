<template>
  <b-container class="container-top">
    <h1>Farm</h1>
    <div class="row" v-if="farm !== null">
      <div class="col">
        <div class="row">
          <h2>{{ farm.name }}</h2>
        </div>
        <div class="row">
          <p>{{ farm.description }}</p>
        </div>
        <div class="row">
          <b-table class="mb-0" striped hover small bordered caption-top caption="Stored plants" :items="stored" :per-page="perPage" :current-page="currentPage"></b-table>
          <b-pagination
            v-if="stored.length > 0"
            v-model="currentPage"
            :total-rows="stored.length"
            :per-page="perPage"
            size="sm"
          ></b-pagination>
        </div>
      </div>
    </div>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'

export default {
  name: 'home',
  data() {
    return {
      farm: null,
      plants: [],
      states: ['Propogated', 'Purchased', 'Dispatched', 'Received', 'Planted'],
      isFarmOwner: false,
      perPage: 10,
      currentPage: 1,
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      this.farmManager.deployed().then((contract) => {
        this.initFarm(contract);

        contract.isFarmOwner(this.$route.params.farmId).then(isFarmer => {
          this.isFarmOwner = isFarmer;
        })
      })

      this.supplyContract.deployed().then((contract) => {
        this.initFarmPlants(contract);
      })
    })
  },
  computed: {
    stored: function() {
      return this.plants.filter(plant => plant.ownerAddress === this.farm.ownerAddress && plant.state === 'Received');
    }
  },
  methods: {
    initFarm: function(contract) {
      // Retrieve farm info
      contract.getFarm(this.$route.params.farmId).then((f) => {
        this.farm = {
          id: f[0].toNumber(),
          name: f[1].toString(),
          lat: f[2].toNumber(),
          long: f[3].toNumber(),
          description: f[4].toString(),
          ownerName: f[5].toString(),
          ownerAddress: f[6].toString()
        }
      })
    },
    initFarmPlants: function(contract) {
      // Get plant info for nursery
      contract.getPlantCount().then((count) => {
        for (var i = 0; i < count; i++) {
          contract.getPlant(i).then((plant) => {
            let p = {
              id: plant[0].toNumber(),
              state: this.states[plant[1].toNumber()],
              plantedDate: new Date(plant[2].toNumber() * 1000),
              lat: plant[3].toNumber(),
              long: plant[4].toNumber(),
              nursery: plant[5].toString(),
              variety: plant[6].toString(),
              ownerAddress: plant[7].toString()
            }
            this.plants.push(p);
          })
        }
      })
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
