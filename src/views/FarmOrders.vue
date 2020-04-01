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
          <b-button v-if="isFarmOwner" v-b-modal.orderModal class="float-left mt-3" variant="primary">Order plants</b-button>
        </div>
        <div class="row mt-3">
          <b-form inline>
            <b-form-group label="Order status:" label-for="order-select">
              <b-form-select id="order-select" size="sm" :options="orderStates" v-model="selectedOrderState"></b-form-select>
            </b-form-group>
          </b-form>
        </div>

        <b-modal id="orderModal" title="Order plants" @ok="orderPlants">
          <b-form>
            <b-form-group label="Nursery" label-for="nursery-select" label-align="left">
              <b-form-select id="nursery-select" size="sm" :options="nurseryOptions" v-model="selectedNursery"></b-form-select>
            </b-form-group>
            <b-form-group label="Order quantity" label-for="nursery-stock" label-align="left">
              <b-form-text>Current stock: {{ nurseryStock }}</b-form-text>
              <b-input id="orderQuantity" size="sm" placeholder="0" type="number" min="0" :max="nurseryStock" v-model="orderQuantity"/>
            </b-form-group>
          </b-form>
        </b-modal>
      </div>
    </div>

    <div class="row mt-3" v-for="order in displayOrders" v-bind:key="order.id">
      <!-- <b-card-group v-for="order in displayOrders" v-bind:key="order.id" class="ml-3"> -->
        <b-card header-text-variant="light" header-bg-variant="dark" class="text-left w-100">
          <template v-slot:header class="m-0">
            <h6 class="mb-0">Order - {{ order.id }}</h6>
          </template>
          <b-card-text class="mb-0">Nursery: {{ order.nurseryName }}</b-card-text>
          <b-card-text class="mb-0">Farm: {{ order.farmName }}</b-card-text>
          <b-card-text class="mb-0">Quantity: {{ order.quantity }}</b-card-text>
          <b-card-text class="mb-0">State: {{ orderStates[order.state] }}</b-card-text>
          <b-card-text class="mb-0">Last updated: {{ order.lastUpdated.toLocaleString() }}</b-card-text>
          <b-button v-if="isFarmOwner && orderStates[order.state] === 'Dispatched'" @click="receive_order(order)">Receive Order</b-button>
        </b-card>
      <!-- </b-card-group> -->
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
      states: ['Propogated', 'Purchased', 'Dispatched', 'Received', 'Stored', 'Planted'],
      orderStates: ['Placed', 'Dispatched', 'Received'],
      selectedOrderState: 'Placed',
      isFarmOwner: false,
      plantedPerPage: 10,
      plantedCurrentPage: 1,
      nurseries: [],
      selectedNursery: null,
      orderQuantity: 0,
      orders: [],
      expanded: false
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      this.farmManager.deployed().then((contract) => {
        this.initFarm(contract);

        contract.isFarmOwner(this.$route.params.farmId).then(isFarmer => {
          this.isFarmOwner = isFarmer;
        })

        this.setupOrderPlacedEvent(contract);
      })

      this.nurseryManager.deployed().then((contract) => {
        this.nurseries = this.getNurseries(contract);
      })

      this.orderManager.deployed().then((contract) => {
        this.orders = this.getOrders(contract);
      })

      this.supplyContract.deployed().then((contract) => {
        this.initFarmPlants(contract);
      })
    })
  },
  computed: {
    received: function() {
      return this.plants.filter(plant => plant.ownerId === this.farm.ownerId && plant.state === 'Received');
    },
    planted: function() {
      return this.plants.filter(plant => plant.ownerId === this.farm.ownerId && plant.state === 'Planted');
    },
    nurseryOptions: function() {
      const opts = [];
      this.nurseries.forEach((nursery) => {
        opts.push({ value: nursery, text: nursery.name})
      })
      return opts;
    },
    nurseryStock: function() {
      if (this.selectedNursery === null) {
        return 0;
      } else {
        return this.plants.filter(plant => plant.nursery === this.selectedNursery.name && plant.state === 'Propogated').length;
      }
    },
    placedOrders: function() {
      return this.orders.filter(order => order.farmName === this.farm.name && this.orderStates[order.state] === 'Placed');
    },
    receivedOrders: function() {
      return this.orders.filter(order => order.farmName === this.farm.name && this.orderStates[order.state] === 'Received');
    },
    displayOrders: function() {
       return this.orders.filter(order => order.farmName === this.farm.name && this.orderStates[order.state] === this.selectedOrderState);
    }
  },
  methods: {
    orderPlants: function() {
      this.orderManager.deployed().then((contract) => {
        // Generate a timestamp to mark the order with
        let date = (new Date()).getTime();
        let timestamp = Math.floor(date / 1000);
        // Create an order using the appropriate contract function
        contract.orderPlants(this.orderQuantity, this.selectedNursery.id, this.farm.id, timestamp);
      }).catch(error => {
        // TODO: Flag to the user in some useful way
        console.log(error);
      }).then(() => {
        // We want to blank out our form fields whether we succeeded or failed
        // hence the placement in a then after the catch
        this.selectedNursery = null;
        this.orderQuantity = null;
      })
    },
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
          ownerId: f[6].toString()
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
    // Setup the event listener which checks for the addition of new farms
    setupOrderPlacedEvent: function(contract) {
      // uint orderId, string nurseryName, string farmName, uint plantIds, OrderState state, uint placedDate
      contract.OrderPlaced().on('data', event => {
        let o = {
          id: event.returnValues.orderId, 
          nurseryName: event.returnValues.nurseryName, 
          farmName: event.returnValues.farmName, 
          quantity: event.returnValues.quantity, 
          state: this.orderStates[event.returnValues.state], 
          lastUpdated: new Date(event.returnValues.placedDate * 1000)
        }

        this.orders.push(o);
      });
    },
    receive_order: function(order) {
      this.orderManager.deployed().then((contract) => {
        let date = (new Date()).getTime();
        let timestamp = Math.floor(date / 1000);
        
        contract.receiveOrder(order.id, timestamp);
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
