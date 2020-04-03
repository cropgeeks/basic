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
          <b-form-group label="Employeed ID" label-for="employee" label-align="left">
            <b-input id="employee" size="sm" v-model="employeeId"></b-input>
          </b-form-group>
          <b-form-group label="Select plant" label-for="plant" label-align="left">
            <b-form-select id="plant" size="sm" :options="options" v-model="toBePlanted"></b-form-select>
          </b-form-group>
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
      planted: [],
      storedPlants: [],
      states: ['Propogated', 'Purchased', 'Dispatched', 'Stored', 'Planted'],
      isFarmOwner: false,
      plantedPerPage: 10,
      plantedCurrentPage: 1,
      employeeId: null,
      toBePlanted: null,
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
  },
  computed: {
    plantDisabled: function() {
      return this.storedPlants.length == 0;
    },
    harvestDisabled: function() {
      return this.planted.length == 0;
    },
    options: function() {
      const opts = [];
      this.storedPlants.forEach((plant) => {
        opts.push({ value: plant, text: plant.id})
      })
      return opts;
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
            if (p.ownerAddress === this.farm.ownerAddress && p.state === 'Planted') {
              this.planted.push(p);
            } else if (p.ownerAddress === this.farm.ownerAddress && p.state === 'Stored') {
              this.storedPlants.push(p);
            }
          })
        }
      })
    },
    plant: function() {
      this.farmManager.deployed().then((contract) => {
        let date = (new Date()).getTime();
        let timestamp = Math.floor(date / 1000);

        contract.plantOnFarm(this.farm.id, this.employeeId, this.toBePlanted.id, timestamp);
      }).catch(error => {
        console.log(error);
      }).then(() => {
        this.employeeId = null;
        this.toBePlanted = null;
      })
    },
    harvest: function() {

    },
    setupPlantedByFarmerEvent: function(contract) {
      // (uint indexed plantId, address plantOwner, uint date, string farmName, string employeeName);
      contract.PlantedByFarmer().on('data', event => {
        let e = {
          plantId: event.returnValues.plantId,
          address: event.returnValues.plantOwner,
          date: event.returnValues.date,
          farmName: event.returnValues.farmName,
          employeeName: event.returnValues.employeeName
        }
        if (e.farmName === this.farm.name) {
          this.planted.push(this.storedPlants.filter(p => p.id === e.plantId));
          this.storedPlants = this.storedPlants.filter(p => p.id !== e.plantId);
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
