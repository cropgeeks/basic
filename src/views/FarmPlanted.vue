<template>
  <b-container class="container-top">
    <b-breadcrumb :items="breadcrumbs"></b-breadcrumb>
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
          <b-button v-b-modal.plantModal :disabled="plantDisabled" variant="primary">Plant</b-button>
          <b-button v-b-modal.harvestModal :disabled="harvestDisabled" variant="primary" class="ml-3">Harvest</b-button>
        </div>
        <div class="row">
          <b-table class="mb-0" striped hover small bordered caption-top caption="Planted plants" :items="planted" :per-page="plantedPerPage" :current-page="plantedCurrentPage"></b-table>
          <b-pagination
            v-if="planted.length > 0"
            v-model="plantedCurrentPage"
            :total-rows="planted.length"
            :per-page="plantedPerPage"
            size="sm"
          ></b-pagination>
        </div>
      </div>
      <b-modal id="plantModal" title="Plant" @ok="plant">
        <b-form>
          <!-- <b-form-group label="Variety" label-for="variety" label-align="left">
            <b-input id="variety" size="sm" v-model="variety"></b-input>
          </b-form-group>
          <b-form-group label="Quantity" label-for="quantity" label-align="left">
            <b-input id="quantity" size="sm" placeholder="1" type="number" min="1" v-model="propQuantity"/>
          </b-form-group> -->
        </b-form>
      </b-modal>

      <b-modal id="harvestModal" title="Plant" @ok="harvest">
        <b-form>
          <!-- <b-form-group label="Variety" label-for="variety" label-align="left">
            <b-input id="variety" size="sm" v-model="variety"></b-input>
          </b-form-group>
          <b-form-group label="Quantity" label-for="quantity" label-align="left">
            <b-input id="quantity" size="sm" placeholder="1" type="number" min="1" v-model="propQuantity"/>
          </b-form-group> -->
        </b-form>
      </b-modal>
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
      states: ['Propogated', 'Purchased', 'Dispatched', 'Stored', 'Planted'],
      isFarmOwner: false,
      plantedPerPage: 10,
      plantedCurrentPage: 1,
      breadcrumbs: [
        {
          text: "Home",
          to: { name: 'home' }
        },
        {
          text: "Farms",
          to: { name: 'farms'}
        },
        {
          text: "Farm",
          to: { name: 'farm', params: { farmId: this.$route.params.farmId }}
        },
        {
          text: "Planted",
          active: true
        }
      ]
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

    console.log("plantDisabled: " + this.plantDisabled);
  },
  computed: {
    planted: function() {
      return this.plants.filter(plant => plant.ownerAddress === this.farm.ownerAddress && plant.state === 'Planted');
    },
    stored: function() {
      return this.plants.filter(plant => plant.ownerAddress === this.farm.ownerAddress && plant.state === 'Stored');
    },
    plantDisabled: function() {
      return this.stored.length == 0;
    },
    harvestDisabled: function() {
      return this.planted.length == 0;
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
    },
    plant: function() {

    },
    harvest: function() {

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
