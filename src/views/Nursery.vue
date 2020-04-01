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
        <div class="row">
          <b-table class="mb-0" striped hover small bordered caption-top caption="Propogated plants" :items="propogated" :per-page="propPerPage" :current-page="propCurrentPage"></b-table>
          <b-pagination
            v-if="propogated.length > 0"
            v-model="propCurrentPage"
            :total-rows="propogated.length"
            :per-page="propPerPage"
            size="sm"
          ></b-pagination>
        </div>
        <!-- <div class="row">
          <b-table class="md-0" striped hover small bordered caption-top caption="Purcahsed &amp; Ready for dispatch" :items="purchased"></b-table>
          <b-pagination
            v-if="purchased.length > 0"
            v-model="purchasedCurrentPage"
            :total-rows="purchased.length"
            :per-page="purchasedPerPage"
            size="sm"
          ></b-pagination>
        </div> -->
        <orders-accordion :orders="placedOrders"
                          :orderStates="orderStates"
                          heading="Placed Orders"
                          :nursery_owner="isNurseryOwner"
                          :farm_owner="false"
                          @dispatch_order="dispatchOrder"
        ></orders-accordion>
        <orders-accordion :orders="dispatchedOrders"
                          :orderStates="orderStates"
                          heading="Dispatched Orders"
                          :nursery_owner="isNurseryOwner"
                          :farm_owner="false"
        ></orders-accordion>
        <b-button v-if="isNurseryOwner" v-b-modal.propogateModal class="float-left" variant="primary">Propogate plants</b-button>
        <b-modal id="propogateModal" title="Propogate plants" @ok="propogatePlants">
          <b-form>
            <b-form-group label="Variety" label-for="variety" label-align="left">
              <b-input id="variety" size="sm" v-model="variety"></b-input>
            </b-form-group>
            <b-form-group label="Quantity" label-for="quantity" label-align="left">
              <b-input id="quantity" size="sm" placeholder="1" type="number" min="1" v-model="propQuantity"/>
            </b-form-group>
          </b-form>
        </b-modal>
      </div>
    </div>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'
import OrdersAccordion from '../components/OrdersAccordion.vue'

export default {
  name: 'home',
  components: {
    "orders-accordion": OrdersAccordion
  },
  data() {
    return {
      nursery: null,
      plants: [],
      states: [ 'Propogated', 'Purchased', 'Dispatched', 'Received', 'Planted'],
      orderStates: ['Placed', 'Dispatched', 'Received'],
      isNurseryOwner: false,
      variety: null,
      propQuantity: null,
      propPerPage: 10,
      propCurrentPage: 1,
      purchasedPerPage: 10,
      purchasedCurrentPage: 1,
      orders: []
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      // Handle account changes
      // web3.currentProvider.publicConfigStore.on('update', (update) => {
      //   const newAddress = update.selectedAddress;
      //   this.defaultAccount = newAddress;
      //   web3.eth.defaultAccount = newAddress;
      //   this.supplyContract.defaults({from: this.w3.eth.defaultAccount})
      // });

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
        this.setupPlantPropogatedEvent(contract);
      })
    })
  },
  computed: {
    propogated: function() {
      return this.plants.filter(plant => plant.nursery === this.nursery.name && plant.state === 'Propogated');
    },
    stock: function() {
      return this.propogated.length;
    },
    placedOrders: function() {
      return this.orders.filter(order => order.nurseryName === this.nursery.name && this.orderStates[order.state] === 'Placed');
    },
    dispatchedOrders: function() {
      return this.orders.filter(order => order.nurseryName === this.nursery.name && this.orderStates[order.state] === 'Dispatched');
    }
  },
  methods: {
    propogatePlants: function() {
      this.supplyContract.deployed().then((contract) => {
        let date = (new Date()).getTime();
        let timestamp = Math.floor(date / 1000);
        contract.propogatePlants(timestamp, this.variety, this.propQuantity, this.nursery.name, this.nursery.lat, this.nursery.long, this.nursery.ownerAddress);
      }).catch(error => {
        console.log(error);
      }).then(() => {
        this.variety = null;
        this.propQuantity = null;
      })
    },
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
    setupPlantPropogatedEvent: function(contract) {
      contract.PropogatedByNursery().on('data', event => {
        let p = {
          id: event.returnValues.plantId,
          state: event.returnValues.state,
          plantedDate: new Date(event.returnValues.date * 1000),
          lat: event.returnValues.lat,
          long: event.returnValues.long,
          nursery: event.returnValues.name,
          variety: event.returnValues.variety,
          ownerAddress: event.returnValues.ownerAddress
        }
        if (p.ownerId === this.nursery.ownerId) {
          this.propogated.push(p);
        }
      })
    },
    dispatchOrder: function(order) {
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
