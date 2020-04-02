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
          <b-button v-b-modal.storeModal variant="primary">Add store</b-button>
        </div>
        <div class="row">
          <b-table class="mb-0" striped hover small bordered caption-top caption="Stored plants" :items="plants" :per-page="perPage" :current-page="currentPage"></b-table>
          <b-pagination
            v-if="plants.length > 0"
            v-model="currentPage"
            :total-rows="plants.length"
            :per-page="perPage"
            size="sm"
          ></b-pagination>
        </div>
      </div>

      <b-modal id="storeModal" title="Plant" @ok="addStore">
        <b-form>
          <b-form-group label="Store name" label-for="name" label-align="left">
            <b-input id="name" size="sm" v-model="storeName"></b-input>
          </b-form-group>
          <b-form-group label="Store temperature" label-for="temperature" label-align="left">
            <b-input id="temperature" type="number" min="-30" max="30"  size="sm" v-model="storeTemperature"></b-input>
          </b-form-group>
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
      perPage: 10,
      currentPage: 1,
      storeTemperature: 5,
      storeName: '',
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
          text: "Storage",
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
            if (p.ownerAddress === this.farm.ownerAddress && p.state === 'Stored') {
              this.plants.push(p);
            }
          })
        }
      })
    },
    addStore: function() {
      this.farmManager.deployed().then((contract) => {
        contract.addFarmStorage(this.farm.id, this.storeName, this.storeTemperature);
      }).catch(error => {
        // TODO: Flag to the user in some useful way
        console.log(error);
      }).then(() => {
        // We want to blank out our form fields whether we succeeded or failed
        // hence the placement in a then after the catch
        this.storeTemperature = 5;
        this.storeName = '';
      })
    },
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
