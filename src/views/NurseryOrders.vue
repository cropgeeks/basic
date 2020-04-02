<template>
  <b-container class="container-top">
    <h1>Nursery</h1>
    <div class="row" v-if="nursery !== null">
      <div class="col">
        <div class="row">
          <h2>{{ nursery.name }}</h2>
        </div>
        <div class="row">
          <p>{{ nursery.description }}</p>
        </div>
        <div class="row mt-3">
          <b-form inline>
            <b-form-group label="Order status:" label-for="order-select">
              <b-form-select id="order-select" size="sm" :options="orderStates" v-model="selectedOrderState"></b-form-select>
            </b-form-group>
          </b-form>
        </div>
      </div>
    </div>

    <div class="row mt-3" v-for="order in displayOrders" v-bind:key="order.id">
        <b-card header-text-variant="light" header-bg-variant="dark" class="text-left w-100">
          <template v-slot:header class="m-0">
            <h6 class="mb-0">Order - {{ order.id }}</h6>
          </template>
          <b-card-text class="mb-0">Nursery: {{ order.nurseryName }}</b-card-text>
          <b-card-text class="mb-0">Farm: {{ order.farmName }}</b-card-text>
          <b-card-text class="mb-0">Quantity: {{ order.quantity }}</b-card-text>
          <b-card-text class="mb-0">State: {{ orderStates[order.state] }}</b-card-text>
          <b-card-text class="mb-0">Last updated: {{ order.lastUpdated.toLocaleString() }}</b-card-text>
          <b-button v-if="isNurseryOwner && orderStates[order.state] === 'Placed'" @click="dispatch_order(order)">Dispatch Order</b-button>
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
      nursery: null,
      orderStates: ['Placed', 'Dispatched', 'Received'],
      selectedOrderState: 'Placed',
      isNurseryOrder: false,
      orders: [],
      plants: [],
      states: [ 'Propogated', 'Purchased', 'Dispatched', 'Stored', 'Planted'],
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      this.nurseryManager.deployed().then((contract) => {
        this.initNursery(contract);

        // Check if the selected account is the nursery owner
        contract.isNurseryOwner(this.$route.params.nurseryId).then(isOwner => {
          this.isNurseryOwner = isOwner;
        })
      })

      this.orderManager.deployed().then((contract) => {
        this.orders = this.getOrders(contract);
        this.setupOrderDispatchedEvent(contract);
      })

      this.supplyContract.deployed().then((contract) => {
        this.initNurseryPlants(contract);
      })
    })
  },
  computed: {
    displayOrders: function() {
       return this.orders.filter(order => order.nurseryName === this.nursery.name && this.orderStates[order.state] === this.selectedOrderState);
    },
    propogated: function() {
      return this.plants.filter(plant => plant.nursery === this.nursery.name && plant.state === 'Propogated');
    }
  },
  methods: {
    initNursery: function(contract) {
      // Retrieve nursery info
      contract.getNursery(this.$route.params.nurseryId).then((n) => {
        this.nursery = {
          id: n[0].toNumber(),
          name: n[1].toString(),
          lat: n[2].toNumber(),
          long: n[3].toNumber(),
          description: n[4].toString(),
          ownerName: n[5].toString(),
          ownerAddress: n[6].toString()
        }
      })
    },
    initNurseryPlants: function(contract) {
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
    dispatch_order: function(order) {
      this.orderManager.deployed().then((contract) => {
        const ordered = this.propogated.slice(0, order.quantity).map(p => p.id);

        let date = (new Date()).getTime();
        let timestamp = Math.floor(date / 1000);

        contract.dispatchOrder(order.id, ordered, timestamp, order.farmName, this.nursery.name, this.nursery.lat, this.nursery.long);
      })
    },
     // Setup the event listener which checks for the addition of new farms
    setupOrderDispatchedEvent: function(contract) {
      contract.OrderDispatched().on('data', event => {
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
