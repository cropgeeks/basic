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
      isFarmer: false,
      quantity: 1,
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

      this.supplyContract.deployed().then((contract) => {
        this.initNursery(contract);
        this.initNurseryPlants(contract);

        this.isNurseryOwner = false;
        this.isFarmer = false;

        // Check if the selected account is the nursery owner
        contract.isNurseryOwner().then(isOwner => {
          this.isNurseryOwner = isOwner;
        })

        // Check if the selected account is the nursery owner
        contract.isFarmer().then(isFarmer => {
          this.isFarmer = isFarmer;
        })

        this.setupPlantPropogatedEvent(contract);

        this.orders = this.getOrders(contract);
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
    }
  },
  methods: {
    propogatePlants: function() {
      this.supplyContract.deployed().then((contract) => {
        let date = (new Date()).getTime();
        let timestamp = Math.floor(date / 1000);
        contract.propogatePlants(timestamp, this.variety, this.propQuantity);
      }).catch(error => {
        console.log(error);
      }).then(() => {
        this.variety = null;
        this.propQuantity = null;
      })
    },
    orderPlants: function() {
      const ordered = this.propogated.slice(0, this.quantity).map(p => p.id);
      this.propogated = this.propogated.slice(this.quantity);

      let date = (new Date()).getTime();
      let timestamp = Math.floor(date / 1000);

      this.supplyContract.deployed().then((contract) => {
        contract.orderPlants(ordered, this.nursery.address, timestamp)
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
          ownerId: n[6].toString()
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
              ownerId: plant[7].toNumber()
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
          ownerId: event.returnValues.ownerId
        }
        if (p.ownerId === this.nursery.ownerId) {
          this.propogated.push(p);
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
