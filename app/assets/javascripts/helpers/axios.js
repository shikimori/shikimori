import axios from 'axios';
import csrf from 'helpers/csrf';

export default axios.create({
  headers: Object.merge(
    csrf().headers,
    { 'X-Requested-With': 'XMLHttpRequest' }
  )
});
